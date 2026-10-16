
# Stage 1: Build and compile the Selenium TestNG project
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy Maven configuration and source code
COPY pom.xml .
COPY src ./src

# Download dependencies
RUN mvn dependency:go-offline -B

# Compile tests without executing them
RUN mvn test-compile

# Stage 2: Runtime environment with Java 17 and Chromium
FROM maven:3.9-eclipse-temurin-17

WORKDIR /app

# Install Chromium and its runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    chromium-driver \
    ca-certificates \
    fonts-liberation \
    libglib2.0-0 \
    libnss3 \
    libfontconfig1 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Copy project files from the build stage
COPY --from=build /app /app

# Configure Chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROME_PATH=/usr/bin/chromium

# Run TestNG tests through Maven
CMD ["mvn", "test"]
