FROM node:18-alpine

WORKDIR /app

# Install git for cloning
RUN apk add --no-cache git

# Clone the repository
RUN git clone https://github.com/aws-samples/serverless-pdf-chat.git /tmp/repo && \
    cp -r /tmp/repo/frontend/* /app/ && \
    rm -rf /tmp/repo

# Copy the modified chat.tsx
COPY chat.tsx src/routes/chat.tsx

# Install dependencies
RUN npm ci

# The actual build will happen in the container
CMD ["sh", "-c", "echo 'Building frontend with env vars' && \
     echo \"VITE_REGION=$VITE_REGION\" > .env && \
     echo \"VITE_API_ENDPOINT=$VITE_API_ENDPOINT\" >> .env && \
     echo \"VITE_USER_POOL_ID=$VITE_USER_POOL_ID\" >> .env && \
     echo \"VITE_USER_POOL_CLIENT_ID=$VITE_USER_POOL_CLIENT_ID\" >> .env && \
     npm run build && \
     cp -r dist/* /output/"]
