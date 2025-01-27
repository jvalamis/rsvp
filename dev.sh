#!/bin/bash

# Start Flutter web server in the background
flutter run -d chrome --web-port=3001 &
FLUTTER_PID=$!

# Start Node.js server with nodemon
npm run dev:web &
NODE_PID=$!

# Function to cleanup child processes
cleanup() {
    echo "Stopping servers..."
    kill $FLUTTER_PID
    kill $NODE_PID
    exit 0
}

# Setup cleanup on script exit
trap cleanup SIGINT SIGTERM

# Wait for either process to exit
wait
