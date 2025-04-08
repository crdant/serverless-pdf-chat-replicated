FROM public.ecr.aws/lambda/python:3.11

# Install common dependencies
RUN pip install --no-cache-dir \
    boto3 \
    aws-lambda-powertools

# Set working directory
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy common files if needed
# COPY common/ ${LAMBDA_TASK_ROOT}/
