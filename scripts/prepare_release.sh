#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_NAME="sbv2srt"
BINARY_NAME="sbv2srt"

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
if [ ! -f "mix.exs" ]; then
    log_error "This script must be run from the project root directory"
    exit 1
fi

# Check if version is provided
if [ -z "$1" ]; then
    log_error "Usage: $0 <version> [--skip-tests]"
    log_info "Example: $0 1.0.0"
    exit 1
fi

VERSION="$1"
SKIP_TESTS="$2"

log_info "Preparing release for version $VERSION"

# Validate version format (semantic versioning)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    log_error "Version must be in semantic versioning format (e.g., 1.0.0)"
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
    log_error "Working directory is not clean. Please commit your changes first."
    exit 1
fi

# Update version in mix.exs
log_info "Updating version in mix.exs..."
sed -i.bak "s/version: \"[^\"]*\"/version: \"$VERSION\"/" mix.exs
rm mix.exs.bak

# Run tests unless skipped
if [ "$SKIP_TESTS" != "--skip-tests" ]; then
    log_info "Running tests..."
    if ! mix test; then
        log_error "Tests failed. Aborting release."
        exit 1
    fi
    log_success "All tests passed"
else
    log_warning "Skipping tests as requested"
fi

# Check dependencies
log_info "Checking dependencies..."
mix deps.get
mix compile

# Build escript for testing
log_info "Building escript..."
if ! mix escript.build; then
    log_error "Failed to build escript"
    exit 1
fi

# Test the escript
log_info "Testing escript functionality..."
echo "0:00:01.000,0:00:04.000
Test subtitle
" > test_release.sbv

if ! ./sbv2srt test_release.sbv test_release.srt; then
    log_error "Escript test failed"
    rm -f test_release.sbv test_release.srt sbv2srt
    exit 1
fi

# Verify output
if [ ! -f "test_release.srt" ]; then
    log_error "Escript did not produce expected output"
    rm -f test_release.sbv sbv2srt
    exit 1
fi

# Clean up test files
rm -f test_release.sbv test_release.srt sbv2srt

log_success "Escript build and test successful"

# Check if we have required tools for standalone builds
MISSING_TOOLS=()
if ! command -v zig &> /dev/null; then
    MISSING_TOOLS+=("zig")
fi
if ! command -v xz &> /dev/null; then
    MISSING_TOOLS+=("xz")
fi
if ! command -v 7z &> /dev/null; then
    MISSING_TOOLS+=("7z")
fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    log_warning "Missing tools for standalone builds: ${MISSING_TOOLS[*]}"
    log_warning "Standalone builds will be skipped"
    BUILD_STANDALONE=false
else
    # Check Zig version
    ZIG_VERSION=$(zig version)
    if [ "$ZIG_VERSION" != "0.14.0" ]; then
        log_warning "Zig version is $ZIG_VERSION, but 0.14.0 is required for standalone builds"
        log_warning "Standalone builds will be skipped"
        BUILD_STANDALONE=false
    else
        BUILD_STANDALONE=true
    fi
fi

# Build standalone binaries if possible
if [ "$BUILD_STANDALONE" = true ]; then
    log_info "Building standalone binaries..."
    
    # Clean previous builds
    rm -rf burrito_out/
    
    # Build for macOS, Linux, and Windows
    if MIX_ENV=prod mix release; then
        log_success "Standalone binaries built successfully"
        ls -la burrito_out/
    else
        log_error "Standalone binary build failed"
        exit 1
    fi
else
    log_warning "Skipping standalone binary builds due to missing requirements"
fi

# Commit the version change
log_info "Committing version change..."
git add mix.exs
git commit -m "Release version $VERSION"

# Create and push tag
log_info "Creating and pushing tag v$VERSION..."
git tag "v$VERSION"
git push origin main
git push origin "v$VERSION"

log_success "Release v$VERSION prepared successfully!"

# Output next steps
echo ""
log_info "Next steps for Homebrew distribution:"
echo "1. Go to your GitHub repository"
echo "2. Create a new release for tag v$VERSION"
echo "3. Wait for GitHub to auto-generate the source tarball"
echo "4. Get the SHA256 checksum and update the Homebrew formula"
echo ""
log_info "Commands to run after GitHub release is created:"
echo ""
echo "# Get SHA256 checksum:"
echo "curl -L https://github.com/petros/sbv2srt/archive/v$VERSION.tar.gz | sha256sum"
echo ""
echo "# Update Formula/sbv2srt.rb with:"
echo "  url \"https://github.com/petros/sbv2srt/archive/refs/tags/v$VERSION.tar.gz\""
echo "  sha256 \"<CHECKSUM_FROM_ABOVE>\""
echo ""
log_info "Then test the formula:"
echo "brew install --build-from-source ./Formula/sbv2srt.rb"
echo "brew test sbv2srt"
echo "brew uninstall sbv2srt"