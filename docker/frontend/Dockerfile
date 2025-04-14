# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Install git for cloning
RUN apk add --no-cache git && \
    git clone https://github.com/aws-samples/serverless-pdf-chat.git /tmp/repo && \
    cp -r /tmp/repo/frontend/* /app/ && \
    rm -rf /tmp/repo

# Create a stub for window.RUNTIME_CONFIG in the global scope
RUN echo 'window.RUNTIME_CONFIG = { \
  apiEndpoint: "http://localhost:3000", \
  region: "us-west-2", \
  userPoolId: "placeholder-user-pool-id", \
  userPoolClientId: "placeholder-client-id" \
};' > src/runtime-config.js

# Add TypeScript declaration for RUNTIME_CONFIG
RUN mkdir -p src/types && \
    echo 'interface Window { \
  RUNTIME_CONFIG: { \
    apiEndpoint: string; \
    region: string; \
    userPoolId: string; \
    userPoolClientId: string; \
  } \
}' > src/types/global.d.ts

# Add the runtime config script to index.html
RUN sed -i '/<head>/a\    <script src="./runtime-config.js"></script>' index.html

# Patch the App.tsx file to use runtime configuration
RUN sed -i 's/import\.meta\.env\.VITE_USER_POOL_ID/window.RUNTIME_CONFIG.userPoolId/g' src/App.tsx && \
    sed -i 's/import\.meta\.env\.VITE_USER_POOL_CLIENT_ID/window.RUNTIME_CONFIG.userPoolClientId/g' src/App.tsx && \
    sed -i 's/import\.meta\.env\.VITE_API_ENDPOINT/window.RUNTIME_CONFIG.apiEndpoint/g' src/App.tsx && \
    sed -i 's/import\.meta\.env\.VITE_API_REGION/window.RUNTIME_CONFIG.region/g' src/App.tsx && \
    cat src/App.tsx | grep RUNTIME_CONFIG

COPY chat.tsx src/pages/chat.tsx

# Install dependencies and build
RUN npm ci && \
    npm run build

# Production stage
FROM nginx:alpine

# Copy the build output from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Create entrypoint script
RUN mkdir -p /docker-entrypoint.d && \
    echo $'#!/bin/sh\n\
\n\
# Generate runtime config from environment variables\n\
cat > /usr/share/nginx/html/runtime-config.js << EOFJS\n\
window.RUNTIME_CONFIG = {\n\
  apiEndpoint: "${VITE_API_ENDPOINT}",\n\
  region: "${VITE_REGION}",\n\
  userPoolId: "${VITE_USER_POOL_ID}",\n\
  userPoolClientId: "${VITE_USER_POOL_CLIENT_ID}"\n\
};\n\
console.log("Runtime configuration loaded:", window.RUNTIME_CONFIG);\n\
EOFJS\n\
\n\
echo "Container starting with configuration:"\n\
echo "  API Endpoint: ${VITE_API_ENDPOINT}"\n\
echo "  Region: ${VITE_REGION}"\n\
echo "  User Pool ID: ${VITE_USER_POOL_ID}"\n\
echo "  User Pool Client ID: ${VITE_USER_POOL_CLIENT_ID}"\n\
' > /docker-entrypoint.d/40-patch-config.sh

RUN chmod +x /docker-entrypoint.d/40-patch-config.sh

# Create nginx configuration for SPA support
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Gzip settings \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript; \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # Cache static assets \
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ { \
        expires 7d; \
        add_header Cache-Control "public, max-age=604800, immutable"; \
    } \
    \
    # Do not cache HTML files \
    location ~* \.html$ { \
        expires -1; \
        add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0"; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Specify the command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]
# Build stage for dependencies
FROM node:18-alpine AS builder

# Install git
RUN apk add --no-cache git

# Clone the repository
RUN git clone https://github.com/aws-samples/serverless-pdf-chat.git /app

# Set working directory
WORKDIR /app/frontend

# Install dependencies
RUN npm ci

# Copy our fixed chat.tsx file
COPY chat.tsx /app/frontend/src/pages/chat.tsx

# Final stage
FROM nginx:alpine

# Install Node.js
RUN apk add --no-cache nodejs npm

# Copy the frontend source code and node_modules
COPY --from=builder /app/frontend /app/frontend
COPY --from=builder /app/frontend/node_modules /app/frontend/node_modules
COPY --from=builder /app/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Create build script in docker-entrypoint.d
RUN mkdir -p /docker-entrypoint.d
RUN echo '#!/bin/sh \n\
echo "Building frontend application with environment variables" \n\
cd /app/frontend \n\
\n\
# Create .env file with the environment variables \n\
echo "VITE_REGION=$VITE_REGION" > .env \n\
echo "VITE_API_ENDPOINT=$VITE_API_ENDPOINT" >> .env \n\
echo "VITE_USER_POOL_ID=$VITE_USER_POOL_ID" >> .env \n\
echo "VITE_USER_POOL_CLIENT_ID=$VITE_USER_POOL_CLIENT_ID" >> .env \n\
\n\
# Build the app \n\
npm run build \n\
\n\
# Copy the built files to nginx html directory \n\
cp -r dist/* /usr/share/nginx/html/ \n\
\n\
echo "Frontend build completed" \n\
' > /docker-entrypoint.d/40-build-app.sh

RUN chmod +x /docker-entrypoint.d/40-build-app.sh

# Expose port
EXPOSE 80
