import os
import json
import boto3
from aws_lambda_powertools import Logger
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationalRetrievalChain
from langchain_community.chat_message_histories import DynamoDBChatMessageHistory
from langchain_community.vectorstores import FAISS
from langchain_aws.chat_models import ChatBedrock
from langchain_aws.embeddings import BedrockEmbeddings


MEMORY_TABLE = os.environ["MEMORY_TABLE"]
BUCKET = os.environ["BUCKET"]
MODEL_ID = os.environ["MODEL_ID"]
EMBEDDING_MODEL_ID = os.environ["EMBEDDING_MODEL_ID"]
# Use REGION environment variable instead of hardcoding us-east-1
AWS_REGION = os.environ.get("REGION", "us-west-2")

s3 = boto3.client("s3")
logger = Logger()


def get_embeddings():
    logger.info(f"Initializing Bedrock client with region {AWS_REGION}")
    bedrock_runtime = boto3.client(
        service_name="bedrock-runtime",
        region_name=AWS_REGION,
    )

    embeddings = BedrockEmbeddings(
        model_id=EMBEDDING_MODEL_ID,
        client=bedrock_runtime,
        region_name=AWS_REGION,
    )
    return embeddings

def get_faiss_index(embeddings, user, file_name):
    logger.info(f"Downloading FAISS index for user {user}, file {file_name}")
    s3.download_file(BUCKET, f"{user}/{file_name}/index.faiss", "/tmp/index.faiss")
    s3.download_file(BUCKET, f"{user}/{file_name}/index.pkl", "/tmp/index.pkl")
    faiss_index = FAISS.load_local("/tmp", embeddings, allow_dangerous_deserialization=True)
    return faiss_index

def create_memory(conversation_id):
    message_history = DynamoDBChatMessageHistory(
        table_name=MEMORY_TABLE, session_id=conversation_id
    )

    memory = ConversationBufferMemory(
        memory_key="chat_history",
        chat_memory=message_history,
        input_key="question",
        output_key="answer",
        return_messages=True,
    )
    return memory

def bedrock_chain(faiss_index, memory, human_input, bedrock_runtime):
    logger.info(f"Creating ChatBedrock with model {MODEL_ID}")
    chat = ChatBedrock(
        model_id=MODEL_ID,
        model_kwargs={'temperature': 0.0},
        client=bedrock_runtime
    )

    chain = ConversationalRetrievalChain.from_llm(
        llm=chat,
        chain_type="stuff",
        retriever=faiss_index.as_retriever(),
        memory=memory,
        return_source_documents=True,
    )

    response = chain.invoke({"question": human_input})

    return response

@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    try:
        event_body = json.loads(event["body"])
        file_name = event_body["fileName"]
        human_input = event_body["prompt"]
        conversation_id = event["pathParameters"]["conversationid"]
        user = event["requestContext"]["authorizer"]["claims"]["sub"]
        
        logger.info(f"Processing request for user {user}, conversation {conversation_id}")
        logger.info(f"File name: {file_name}, Prompt: {human_input}")

        embeddings = get_embeddings()
        faiss_index = get_faiss_index(embeddings, user, file_name)
        memory = create_memory(conversation_id)
        
        # Use the same region for the Bedrock runtime client
        bedrock_runtime = boto3.client(
            service_name="bedrock-runtime",
            region_name=AWS_REGION,
        )

        response = bedrock_chain(faiss_index, memory, human_input, bedrock_runtime)
        if response:
            logger.info(f"{MODEL_ID} -\nPrompt: {human_input}\n\nResponse: {response['answer']}")
        else:
            raise ValueError(f"Unsupported model ID: {MODEL_ID}")

        logger.info(str(response['answer']))

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "*",
            },
            "body": json.dumps(response['answer']),
        }
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "*",
            },
            "body": json.dumps({"error": f"An error occurred: {str(e)}"}),
        }
