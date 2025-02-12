# Use official Dart image as base
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Install Flutter more efficiently
RUN git clone --depth 1 https://github.com/flutter/flutter.git -b main /flutter
ENV PATH="/flutter/bin:$PATH"
ENV FLUTTER_ENV=production

# Copy only necessary files first
COPY pubspec.* ./
RUN flutter pub get

# Now copy the rest and build
COPY . .
RUN flutter build web --release --base-href "/rsvp/"

# Serve using Dart
EXPOSE 3000
CMD ["dart", "run", "bin/server.dart"] 