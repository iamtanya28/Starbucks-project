### --------- Stage 1: Sonar Scanner & Build ---------
FROM node:18-alpine AS build

# Install dependencies for SonarScanner
RUN apk add --no-cache curl unzip openjdk11

# Install SonarScanner CLI
ENV SONAR_SCANNER_VERSION=5.0.1.3006
RUN curl -Lo /tmp/sonar.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    unzip /tmp/sonar.zip -d /opt && \
    rm /tmp/sonar.zip && \
    ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set working directory
WORKDIR /app

# Copy app code and install dependencies
COPY package.json package-lock.json /app/
RUN npm install

COPY . .

# Run SonarQube scan (optional here if you want it during image build)
# RUN sonar-scanner \
#     -Dsonar.projectKey=starbucks \
#     -Dsonar.projectName=starbucks \
#     -Dsonar.sources=.

### --------- Stage 2: Runtime Container ---------
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy only the built app from the previous stage
COPY --from=build /app /app

# Install runtime dependencies only (if needed)
RUN npm install --omit=dev

# Expose the application port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
