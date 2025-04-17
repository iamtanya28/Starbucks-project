# Stage 1: Build Stage
FROM node:alpine AS builder

WORKDIR /app

RUN apk add --no-cache curl unzip git

COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build # Ensure the build step creates necessary files

RUN curl -o sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip sonar-scanner.zip && \
    mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner && \
    rm -rf sonar-scanner.zip

# Stage 2: Runtime Stage
FROM node:alpine AS runtime

WORKDIR /app

# Copy everything from the builder stage
COPY --from=builder /app .

EXPOSE 3000    

CMD ["npm", "start"]
