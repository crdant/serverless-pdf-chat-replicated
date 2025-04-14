FROM public.ecr.aws/lambda/python:3.11-arm64

# Create the lambda function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Set the handler
CMD [ "lambda_function.lambda_handler" ]
FROM public.ecr.aws/lambda/python:3.11-arm64

# Copy the lambda function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Set the handler
CMD [ "lambda_function.lambda_handler" ]
FROM public.ecr.aws/lambda/python:3.11-arm64

# Copy function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Install required packages
RUN pip install aws-lambda-powertools boto3

# Set the handler
CMD [ "lambda_function.lambda_handler" ]
FROM public.ecr.aws/lambda/python:3.11-arm64

# Create the lambda function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Set the handler
CMD [ "lambda_function.lambda_handler" ]
