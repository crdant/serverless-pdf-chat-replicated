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
