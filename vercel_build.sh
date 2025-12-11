#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter Version:"
flutter --version

echo "Enabling Web Support..."
flutter config --enable-web

echo "Building Project..."
# Using the fix for icon tree shaking
flutter build web --release --no-tree-shake-icons

echo "Build Successful!"
