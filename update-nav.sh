#!/bin/bash

# Simple script to update navigation across all pages
# This script will update all navigation components and then inject them into all HTML pages

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[INFO]${NC} Updating navigation across all pages..."

# Run the build script to inject navigation
./build.sh inject-nav

echo -e "${GREEN}[SUCCESS]${NC} Navigation updated across all pages!"
echo -e "${BLUE}[INFO]${NC} To modify navigation, edit the files in public/components/:"
echo -e "  - nav-root.html (for files in public/ root)"
echo -e "  - nav-level1.html (for files one level deep like public/microblog/)"
echo -e "  - nav-level2.html (for files two levels deep like public/posts/thoughts/)"
echo -e "${BLUE}[INFO]${NC} After editing navigation files, run this script again to update all pages."
