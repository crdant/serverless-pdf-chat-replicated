FROM public.ecr.aws/lambda/python:3.11

# Install git for cloning
RUN yum install -y git && \
    git clone https://github.com/aws-samples/serverless-pdf-chat.git /tmp/repo && \
    cp -r /tmp/repo/backend/src/generate_response/* ${LAMBDA_TASK_ROOT}/ && \
    if [ -f "${LAMBDA_TASK_ROOT}/requirements.txt" ]; then pip install -r ${LAMBDA_TASK_ROOT}/requirements.txt; fi && \
    yum remove -y git && yum clean all && \
    rm -rf /tmp/repo

# Set the handler
CMD [ "lambda_function.lambda_handler" ]
