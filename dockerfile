# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Copy dependency files first (better caching)
COPY package*.json ./
COPY tailwind.config.js ./
COPY postcss.config.js ./

# Install dependencies
RUN npm config set registry https://registry.npmmirror.com \
  && npm install --fetch-retries=5 --fetch-retry-mintimeout=20000

# Copy remaining files and build
COPY . .
RUN npm run build  # Creates /app/build directory

# Stage 2: Production
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html

# Remove default Nginx static files
RUN rm -rf ./*

# Copy build output from builder
COPY --from=builder /app/build ./

# Copy custom Nginx configuration if needed
# Uncomment the following line if you have a custom nginx.conf
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Nginx runs as default user
CMD ["nginx", "-g", "daemon off;"]
