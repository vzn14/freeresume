#!/bin/bash

# Render Deployment Script for Free Resume Builder
# This script helps with deployment setup and configuration

set -e

echo "🚀 Setting up Free Resume Builder for Render deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required files exist
print_status "Checking required files..."

required_files=("package.json" "render.yaml" ".env.production" "DEPLOYMENT.md")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "✓ $file exists"
    else
        print_error "✗ $file is missing"
        exit 1
    fi
done

# Check Node.js version
print_status "Checking Node.js version..."
NODE_VERSION=$(node --version)
print_status "Current Node.js version: $NODE_VERSION"

if [[ "$NODE_VERSION" != v22* ]]; then
    print_warning "Recommended Node.js version is 22.x.x, current is $NODE_VERSION"
fi

# Check if pnpm is installed
print_status "Checking pnpm installation..."
if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm --version)
    print_status "✓ pnpm is installed (version: $PNPM_VERSION)"
else
    print_warning "pnpm is not installed. Installing pnpm..."
    npm install -g pnpm
fi

# Install dependencies
print_status "Installing dependencies..."
pnpm install

# Generate Prisma client
print_status "Generating Prisma client..."
pnpm prisma:generate

# Test build
print_status "Testing build process..."
pnpm build

if [ $? -eq 0 ]; then
    print_status "✓ Build successful!"
else
    print_error "✗ Build failed!"
    exit 1
fi

# Create environment file for local testing
if [ ! -f ".env" ]; then
    print_status "Creating local .env file from template..."
    cp .env.production .env
    print_warning "Please update .env file with your local configuration"
fi

# Display deployment instructions
echo ""
print_status "🎉 Setup complete! Ready for Render deployment."
echo ""
print_status "Next steps:"
echo "1. Push your code to GitHub"
echo "2. Connect your repository to Render"
echo "3. Follow the instructions in DEPLOYMENT.md"
echo ""
print_status "Or deploy via Render CLI:"
echo "   render-cli deploy"
echo ""
print_status "For detailed instructions, see DEPLOYMENT.md"

echo ""
print_status "Environment variables to set in Render:"
echo "   - DATABASE_URL (auto-generated)"
echo "   - ACCESS_TOKEN_SECRET (generate random 32-char string)"
echo "   - REFRESH_TOKEN_SECRET (generate random 32-char string)"
echo "   - PUBLIC_URL (your domain or render URL)"
echo "   - VITE_SERVER_URL (backend URL for frontend)"
echo ""

print_status "Project is ready for deployment! 🚀"