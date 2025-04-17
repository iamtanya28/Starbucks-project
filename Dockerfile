# Stage 1: Build Stage
FROM node:alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies required for building the app
RUN apk add --no-cache curl unzip git openjdk17

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package.json package-lock.json ./

# Install all dependencies, including dev dependencies
RUN npm install

# Copy the entire source code
COPY . .

# Build the application (if applicable)
RUN npm run build

# Install Sonar Scanner CLI
RUN curl -o sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip sonar-scanner.zip && \
    mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner && \
    rm -rf sonar-scanner.zip

# Stage 2: Runtime Stage (Final, Minimal Image)
FROM node:alpine AS runtime

# Set working directory
WORKDIR /app

# Install only runtime dependencies (skip dev dependencies)
RUN apk add --no-cache openjdk17

# Copy built application and dependencies from builder stage
COPY --from=builder /app .

# Expose the application port
EXPOSE 3000    

# Define the default startup command
CMD ["npm", "start"]
