# Step 1: Official Ubuntu with Flutter Web Build
FROM ubuntu:22.04 AS build

# Prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK directly from official repository
RUN git clone https://github.com/flutter/flutter.git -b stable /sdks/flutter
ENV PATH="/sdks/flutter/bin:${PATH}"

# Verify & Enable Web
RUN flutter config --enable-web
RUN flutter doctor -v

# Build Flutter Web Project
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Step 2: Serve Web Output using Lightweight Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
