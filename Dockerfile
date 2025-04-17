# ---------- Stage 1: Build & Sonar ----------
FROM node:alpine AS build

# Install build-time tools
RUN apk add --no-cache curl unzip openjdk11

# Install SonarScanner
ENV SONAR_SCANNER_VERSION=5.0.1.3006
RUN curl -o /tmp/sonar.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    unzip /tmp/sonar.zip -d /opt && \
    rm /tmp/sonar.zip && \
    ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set work directory
WORKDIR /app

# Copy only package files and install deps
COPY package*.json ./
RUN npm install

# Copy rest of the app
COPY . .

# Optional: run tests or lint here if needed
# RUN npm test

# ---------- Stage 2: Production Image ----------
FROM node:alpine

# Create app directory
WORKDIR /app

# Copy only the needed runtime files from the build stage
COPY --from=build /app /app

# Install only production dependencies
RUN npm install --production

# Expose the app port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
