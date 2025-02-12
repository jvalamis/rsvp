# Use official Dart image as base
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:$PATH"
ENV FLUTTER_ENV=production

# Initialize git for pub get
RUN git config --global --add safe.directory /flutter

# Copy only necessary files first
COPY pubspec.* ./
RUN git init && flutter pub get

# Now copy the rest and build
COPY . .
RUN flutter build web --release --base-href "/rsvp/"

# Serve using Dart
EXPOSE 3000
CMD ["dart", "run", "bin/server.dart"]
