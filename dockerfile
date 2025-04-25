# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Copy dependency files first (better caching)
COPY package*.json ./
COPY tailwind.config.js ./
COPY postcss.config.js ./

# Install dependencies hello
RUN npm config set registry https://registry.npmmirror.com \
    && npm install --fetch-retries=5 --fetch-retry-mintimeout=20000

# Copy remaining files and build
COPY . .
RUN npm run build  # Creates /app/build directory

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app

# Install serve globally as root first
RUN npm install -g serve

# Create non-root user and set permissions
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser && \
    chown -R appuser:appgroup /app

# Copy build output from builder
COPY --from=builder --chown=appuser:appgroup /app/build ./build

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/ || exit 1

# Switch to non-root user
USER appuser

EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]