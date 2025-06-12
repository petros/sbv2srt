#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "Formula/sbv2srt.rb" ]; then
    log_error "This script must be run from the project root directory"
    log_error "Formula/sbv2srt.rb not found"
    exit 1
fi

# Check if version is provided
if [ -z "$1" ]; then
    log_error "Usage: $0 <version> [checksum]"
    log_info "Example: $0 1.0.0"
    log_info "Example: $0 1.0.0 abc123def456..."
    log_info ""
    log_info "If checksum is not provided, the script will download and calculate it"
    exit 1
fi

VERSION="$1"
PROVIDED_CHECKSUM="$2"

# Validate version format (semantic versioning)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    log_error "Version must be in semantic versioning format (e.g., 1.0.0)"
    exit 1
fi

log_info "Updating Homebrew formula for version $VERSION"

# Build the URL
TARBALL_URL="https://github.com/petros/sbv2srt/archive/refs/tags/v$VERSION.tar.gz"

# Get checksum if not provided
if [ -z "$PROVIDED_CHECKSUM" ]; then
    log_info "Downloading tarball to calculate SHA256 checksum..."
    log_info "URL: $TARBALL_URL"
    
    # Check if the URL is accessible
    if ! curl -f -s -I "$TARBALL_URL" > /dev/null; then
        log_error "Unable to access tarball at $TARBALL_URL"
        log_error "Make sure the GitHub release v$VERSION exists"
        exit 1
    fi
    
    # Download and calculate checksum
    CHECKSUM=$(curl -L -s "$TARBALL_URL" | sha256sum | cut -d' ' -f1)
    
    if [ -z "$CHECKSUM" ]; then
        log_error "Failed to calculate checksum"
        exit 1
    fi
    
    log_success "Calculated SHA256: $CHECKSUM"
else
    CHECKSUM="$PROVIDED_CHECKSUM"
    log_info "Using provided checksum: $CHECKSUM"
fi

# Create backup of formula
cp Formula/sbv2srt.rb Formula/sbv2srt.rb.backup
log_info "Created backup: Formula/sbv2srt.rb.backup"

# Update the formula
log_info "Updating Formula/sbv2srt.rb..."

# Update URL line
sed -i.tmp "s|url \"https://github.com/petros/sbv2srt/archive/refs/tags/v[^\"]*\.tar\.gz\"|url \"$TARBALL_URL\"|" Formula/sbv2srt.rb

# Update SHA256 line
sed -i.tmp "s/sha256 \"[^\"]*\"/sha256 \"$CHECKSUM\"/" Formula/sbv2srt.rb

# Clean up temp file
rm -f Formula/sbv2srt.rb.tmp

log_success "Formula updated successfully!"

# Show what was changed
echo ""
log_info "Changes made to Formula/sbv2srt.rb:"
echo "  url: $TARBALL_URL"
echo "  sha256: $CHECKSUM"

# Test the formula if requested
echo ""
read -p "Do you want to test the formula now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Testing formula..."
    
    log_info "Installing from source..."
    if brew install --build-from-source ./Formula/sbv2srt.rb; then
        log_success "Installation successful"
        
        log_info "Running formula tests..."
        if brew test sbv2srt; then
            log_success "Tests passed"
        else
            log_error "Tests failed"
        fi
        
        log_info "Uninstalling..."
        brew uninstall sbv2srt
        log_success "Cleanup complete"
    else
        log_error "Installation failed"
        echo ""
        log_info "You can restore the backup with:"
        echo "mv Formula/sbv2srt.rb.backup Formula/sbv2srt.rb"
        exit 1
    fi
fi

echo ""
log_success "Formula update complete!"
log_info "Backup saved as: Formula/sbv2srt.rb.backup"
echo ""
log_info "Next steps:"
echo "1. Review the changes: git diff Formula/sbv2srt.rb"
echo "2. Commit the changes: git add Formula/sbv2srt.rb && git commit -m 'Update formula to v$VERSION'"
echo "3. Submit to Homebrew or update your tap"