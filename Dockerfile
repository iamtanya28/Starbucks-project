# Stage 1: Build Stage
FROM node:alpine AS builder

# Set working directory
WORKDIR /app

# Install build dependencies (Java, curl, unzip)
RUN apk add --no-cache openjdk17 curl unzip

# Copy package.json and package-lock.json first for caching
COPY package.json package-lock.json ./

# Install dependencies (including dev dependencies for build process)
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the application (if required)
RUN npm run build || echo "No build step needed"

# Install Sonar Scanner
RUN curl -o sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip sonar-scanner.zip && \
    mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner && \
    rm -rf sonar-scanner.zip

# Stage 2: Runtime Stage (Final, Minimal Image)
FROM node:alpine AS runtime

# Set working directory
WORKDIR /app

# Install only required runtime dependencies
RUN apk add --no-cache openjdk17

# Copy built application from builder stage
COPY --from=builder /app .

# Set Java path explicitly for Sonar Scanner
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV SONAR_SCANNER_OPTS="-Djava.home=$JAVA_HOME"

EXPOSE 3000

CMD ["npm", "start"]
