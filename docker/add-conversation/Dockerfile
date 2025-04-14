FROM public.ecr.aws/lambda/python:3.11-arm64

# Debug: Show Python path
RUN python -c "import sys; print('Python search path:')" && \
    python -c "import sys; [print(p) for p in sys.path]"

# Install git and required packages directly to Lambda task root
RUN yum install -y git && \
    # Install packages directly to Lambda task root to ensure they're in the Python path
    pip install aws-lambda-powertools boto3 -t ${LAMBDA_TASK_ROOT} && \
    # Clone the repo and copy function code
    git clone https://github.com/aws-samples/serverless-pdf-chat.git /tmp/repo && \
    cp -r /tmp/repo/backend/src/add_conversation/* ${LAMBDA_TASK_ROOT}/ && \
    # Install any additional requirements
    if [ -f "${LAMBDA_TASK_ROOT}/requirements.txt" ]; then pip install -r ${LAMBDA_TASK_ROOT}/requirements.txt -t ${LAMBDA_TASK_ROOT}; fi && \
    # Clean up
    yum remove -y git && yum clean all && \
    rm -rf /tmp/repo

# Verify the installation
RUN ls -la ${LAMBDA_TASK_ROOT} && \
    python -c "import sys; print('After installation Python search path:')" && \
    python -c "import sys; [print(p) for p in sys.path]" && \
    python -c "import aws_lambda_powertools; print(f'aws_lambda_powertools location: {aws_lambda_powertools.__file__}')" || echo "Failed to import aws_lambda_powertools"

# Set the handler
CMD [ "main.lambda_handler" ]
