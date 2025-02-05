# Use official Dart image as base
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:$PATH"
ENV FLUTTER_ENV=production

# Copy files
COPY . .

# Get dependencies
RUN flutter pub get

# Build web
RUN flutter build web

# Serve using Dart
EXPOSE 3000
CMD ["dart", "run", "bin/server.dart"] 