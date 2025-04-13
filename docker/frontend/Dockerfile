# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Install git for cloning
RUN apk add --no-cache git && \
    git clone https://github.com/aws-samples/serverless-pdf-chat.git /tmp/repo && \
    cp -r /tmp/repo/frontend/* /app/ && \
    rm -rf /tmp/repo

# Install dependencies and build
RUN npm ci && \
    npm run build

# Production stage
FROM nginx:alpine

# Copy the build output from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Create runtime configuration files
RUN echo 'window.RUNTIME_CONFIG = {};' > /usr/share/nginx/html/config.js && \
    echo '(function() {\
  const checkAmplify = setInterval(() => {\
    if (window.aws_amplify) {\
      clearInterval(checkAmplify);\
      \
      console.log("Patching Amplify configuration with runtime values");\
      \
      window.aws_amplify.Amplify.configure({\
        Auth: {\
          region: window.RUNTIME_CONFIG.region,\
          userPoolId: window.RUNTIME_CONFIG.userPoolId,\
          userPoolWebClientId: window.RUNTIME_CONFIG.userPoolClientId\
        },\
        API: {\
          endpoints: [\
            {\
              name: "ServerlessPdfChat",\
              endpoint: window.RUNTIME_CONFIG.apiEndpoint\
            }\
          ]\
        }\
      });\
      \
      console.log("Amplify configuration patched successfully");\
    } else {\
      console.log("Waiting for Amplify to load...");\
    }\
  }, 100);\
})();' > /usr/share/nginx/html/amplify-patch.js

# Create entrypoint script
RUN mkdir -p /docker-entrypoint.d && \
    echo '#!/bin/sh\

# Generate runtime config from environment variables\
cat > /usr/share/nginx/html/config.js << EOFJS\
window.RUNTIME_CONFIG = {\
  apiEndpoint: "${VITE_API_ENDPOINT}",\
  region: "${VITE_REGION}",\
  userPoolId: "${VITE_USER_POOL_ID}",\
  userPoolClientId: "${VITE_USER_POOL_CLIENT_ID}"\
};\
console.log("Runtime configuration loaded:", window.RUNTIME_CONFIG);\
EOFJS\
\
# Modify index.html to include our runtime scripts\
if ! grep -q "config.js" /usr/share/nginx/html/index.html; then\
  sed -i "/<head>/a\\  <script src=\"/amplify-patch.js\"></script>" /usr/share/nginx/html/index.html\
  sed -i "/<head>/a\\  <script src=\"/config.js\"></script>" /usr/share/nginx/html/index.html\
fi\
\
echo "Container starting with configuration:"\
echo "  API Endpoint: ${VITE_API_ENDPOINT}"\
echo "  Region: ${VITE_REGION}"\
echo "  User Pool ID: ${VITE_USER_POOL_ID}"\
echo "  User Pool Client ID: ${VITE_USER_POOL_CLIENT_ID}"\
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
