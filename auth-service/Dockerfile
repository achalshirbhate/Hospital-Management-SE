# Use Maven image to build the application
FROM maven:3.9-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Use JRE for runtime (smaller image)
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built jar from build stage
COPY --from=build /app/target/auth-service-0.0.1-SNAPSHOT.jar app.jar

# Expose port (Render will inject PORT env variable)
EXPOSE ${PORT:-8081}

# Run the application
CMD ["java", "-Xmx400m", "-Xms200m", "-jar", "app.jar"]
