FROM node:alpine

# Install required tools
RUN apk add --no-cache curl unzip openjdk11

# Install SonarScanner
ENV SONAR_SCANNER_VERSION=5.0.1.3006
RUN curl -o /tmp/sonar.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    unzip /tmp/sonar.zip -d /opt && \
    rm /tmp/sonar.zip && \
    ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Create working directory
WORKDIR /app

# Copy and install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Expose the app port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
