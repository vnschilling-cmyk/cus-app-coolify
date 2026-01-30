# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files first to cache dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the app
COPY . .

# Build the web application
RUN flutter build web --release

# Stage 2: Serve
FROM nginx:alpine

# Copy the build artifacts from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config if needed (optional, using default for now)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
