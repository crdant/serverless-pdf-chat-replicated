FROM public.ecr.aws/lambda/python:3.11-arm64

# Debug: Show Python path
RUN python -c "import sys; print('Python search path:')" && \
    python -c "import sys; [print(p) for p in sys.path]"

# Copy function code
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Install packages directly to Lambda task root to ensure they're in the Python path
RUN pip install aws-lambda-powertools boto3 -t ${LAMBDA_TASK_ROOT}

# Verify the installation
RUN ls -la ${LAMBDA_TASK_ROOT} && \
    python -c "import sys; print('After installation Python search path:')" && \
    python -c "import sys; [print(p) for p in sys.path]" && \
    python -c "import aws_lambda_powertools; print(f'aws_lambda_powertools location: {aws_lambda_powertools.__file__}')" || echo "Failed to import aws_lambda_powertools"

# Set the handler
CMD [ "lambda_function.lambda_handler" ]
