# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Install git for cloning
RUN apk add --no-cache git && \
    git clone https://github.com/aws-samples/serverless-pdf-chat.git /tmp/repo && \
    cp -r /tmp/repo/frontend/* /app/ && \
    rm -rf /tmp/repo

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
    echo $'#!/bin/sh \n\
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
' > /docker-entrypoint.d/40-build-frontend.sh

RUN chmod +x /docker-entrypoint.d/40-build-frontend.sh

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
