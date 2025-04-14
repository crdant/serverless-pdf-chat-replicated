import os
import json
import boto3
from aws_lambda_powertools import Logger
from langchain.indexes import VectorstoreIndexCreator
from langchain_aws.embeddings import BedrockEmbeddings
from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import FAISS


DOCUMENT_TABLE = os.environ["DOCUMENT_TABLE"]
BUCKET = os.environ["BUCKET"]
EMBEDDING_MODEL_ID = os.environ["EMBEDDING_MODEL_ID"]
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")  # Default to us-east-1 if not set

s3 = boto3.client("s3")
ddb = boto3.resource("dynamodb")
document_table = ddb.Table(DOCUMENT_TABLE)
logger = Logger()


def set_doc_status(user_id, document_id, status):
    logger.info(f"Setting document status to {status} for user {user_id}, document {document_id}")
    document_table.update_item(
        Key={"userid": user_id, "documentid": document_id},
        UpdateExpression="SET docstatus = :docstatus",
        ExpressionAttributeValues={":docstatus": status},
    )


@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    try:
        logger.info("Starting embedding generation process")
        event_body = json.loads(event["Records"][0]["body"])
        document_id = event_body["documentid"]
        user_id = event_body["user"]
        key = event_body["key"]
        file_name_full = key.split("/")[-1]
        
        logger.info(f"Processing document: {file_name_full} for user: {user_id}, document ID: {document_id}")
        set_doc_status(user_id, document_id, "PROCESSING")

        # Download file from S3
        local_path = f"/tmp/{file_name_full}"
        logger.info(f"Downloading file from S3: {BUCKET}/{key} to {local_path}")
        s3.download_file(BUCKET, key, local_path)
        
        # Load PDF
        logger.info(f"Loading PDF from {local_path}")
        loader = PyPDFLoader(local_path)
        documents = loader.load()
        
        if not documents:
            logger.error(f"No content could be extracted from {file_name_full}")
            set_doc_status(user_id, document_id, "ERROR")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Could not extract content from PDF"})
            }
        
        logger.info(f"Successfully loaded {len(documents)} document chunks from PDF")
        
        # Initialize Bedrock client
        logger.info(f"Initializing Bedrock client with model ID: {EMBEDDING_MODEL_ID} in region: {AWS_REGION}")
        bedrock_runtime = boto3.client(
            service_name="bedrock-runtime",
            region_name=AWS_REGION,
        )

        # Initialize embeddings
        logger.info("Creating BedrockEmbeddings instance")
        embeddings = BedrockEmbeddings(
            model_id=EMBEDDING_MODEL_ID,
            client=bedrock_runtime,
            region_name=AWS_REGION,
        )
        
        # Test embedding model
        try:
            logger.info("Testing embedding model with a sample text")
            test_embedding = embeddings.embed_query("Test embedding model")
            logger.info(f"Embedding model test successful. Dimension: {len(test_embedding)}")
        except Exception as e:
            logger.error(f"Bedrock embedding model test failed: {str(e)}")
            set_doc_status(user_id, document_id, "ERROR")
            return {
                "statusCode": 500,
                "body": json.dumps({"error": f"Embedding model error: {str(e)}"})
            }

        # Create index
        logger.info("Creating vector index")
        index_creator = VectorstoreIndexCreator(
            vectorstore_cls=FAISS,
            embedding=embeddings,
        )

        try:
            logger.info("Generating embeddings from document chunks")
            index_from_loader = index_creator.from_loaders([loader])
            logger.info("Successfully created embeddings and index")
        except Exception as e:
            logger.error(f"Error creating embeddings: {str(e)}")
            set_doc_status(user_id, document_id, "ERROR")
            return {
                "statusCode": 500,
                "body": json.dumps({"error": f"Failed to process document: {str(e)}"})
            }

        # Save index locally
        logger.info("Saving index to local filesystem")
        index_from_loader.vectorstore.save_local("/tmp")

        # Upload index to S3
        logger.info(f"Uploading index files to S3 bucket: {BUCKET}")
        s3.upload_file(
            "/tmp/index.faiss", BUCKET, f"{user_id}/{file_name_full}/index.faiss"
        )
        s3.upload_file("/tmp/index.pkl", BUCKET, f"{user_id}/{file_name_full}/index.pkl")

        # Update document status
        logger.info("Setting document status to READY")
        set_doc_status(user_id, document_id, "READY")
        
        logger.info("Embedding generation process completed successfully")
        return {
            "statusCode": 200,
            "body": json.dumps({"status": "success"})
        }
        
    except Exception as e:
        logger.error(f"Unexpected error in lambda_handler: {str(e)}", exc_info=True)
        try:
            set_doc_status(user_id, document_id, "ERROR")
        except Exception:
            logger.error("Could not set document status to ERROR", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Unexpected error: {str(e)}"})
        }
