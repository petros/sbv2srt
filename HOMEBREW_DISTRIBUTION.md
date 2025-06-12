# Homebrew Distribution Guide

This document outlines the steps to distribute `sbv2srt` via Homebrew.

## Prerequisites

1. **GitHub Repository**: The project must be hosted on GitHub with public access
2. **Stable Releases**: Use semantic versioning (e.g., 1.0.0, 1.1.0)
3. **License**: MIT license (already included)
4. **Tests**: Working test suite
5. **Documentation**: Comprehensive README

## Release Process

### 1. Prepare Release

Use the provided script to prepare a new release:

```bash
./scripts/prepare_release.sh 1.0.0
```

This script will:
- Update version in `mix.exs`
- Run tests
- Build and test escript
- Commit changes
- Create and push git tag

### 2. Create GitHub Release

1. Go to your GitHub repository
2. Click "Releases" → "Create a new release"
3. Select the tag created by the script (e.g., `v1.0.0`)
4. Add release notes describing changes
5. Publish the release

GitHub will automatically create a source tarball at:
`https://github.com/petros/sbv2srt/archive/v1.0.0.tar.gz`

### 3. Update Homebrew Formula

#### Option A: Automated (Recommended)

Use the provided helper script to automatically update the formula:

```bash
./scripts/update_formula.sh 1.0.0
```

This script will:
- Download the GitHub release tarball
- Calculate the SHA256 checksum automatically
- Update the formula with correct version and checksum
- Optionally test the formula for you

#### Option B: Manual

Calculate the checksum of the source tarball:

```bash
curl -L https://github.com/petros/sbv2srt/archive/v1.0.0.tar.gz | sha256sum
```

Then manually edit `Formula/sbv2srt.rb` with the new version and checksum.

## Homebrew Formula

### Option 1: Core Formula (Recommended)

Submit to the main Homebrew repository for maximum visibility:

1. **Update the formula**: Use the automated script or manually edit `Formula/sbv2srt.rb` with:
   - Correct version number
   - Calculated SHA256 checksum

2. **Test locally**:
   ```bash
   brew install --build-from-source ./Formula/sbv2srt.rb
   brew test sbv2srt
   brew uninstall sbv2srt
   ```

3. **Submit to Homebrew Core**:
   ```bash
   # Fork homebrew-core repository
   git clone https://github.com/Homebrew/homebrew-core
   cd homebrew-core
   
   # Create new formula
   cp /path/to/sbv2srt/Formula/sbv2srt.rb Formula/sbv2srt.rb
   
   # Test and submit PR
   brew install --build-from-source Formula/sbv2srt.rb
   brew test sbv2srt
   brew audit --new-formula sbv2srt
   ```

4. **Create Pull Request** to homebrew-core with:
   - Clear description of the tool
   - Confirmation that tests pass
   - Notable users or use cases

### Option 2: Personal Tap

Create your own Homebrew tap for easier maintenance:

1. **Create tap repository**:
   ```bash
   # Repository name must be: homebrew-[tapname]
   # Example: homebrew-tools
   git clone https://github.com/petros/homebrew-tools
   ```

2. **Add formula**:
   ```bash
   cp Formula/sbv2srt.rb homebrew-tools/Formula/
   cd homebrew-tools
   git add Formula/sbv2srt.rb
   git commit -m "Add sbv2srt formula"
   git push
   ```

3. **Users install with**:
   ```bash
   brew tap petros/tools
   brew install sbv2srt
   ```

## Formula Requirements

The Homebrew formula must:

- ✅ Build from source (no pre-compiled binaries)
- ✅ Include comprehensive tests
- ✅ Use semantic versioning
- ✅ Have a stable homepage URL
- ✅ Include proper license
- ✅ Work on supported macOS versions
- ✅ Have minimal dependencies

## Testing Checklist

Before submitting to Homebrew:

- [ ] Formula builds successfully on macOS
- [ ] All tests pass (`brew test sbv2srt`)
- [ ] Formula passes audit (`brew audit sbv2srt`)
- [ ] Installation works (`brew install sbv2srt`)
- [ ] Binary functions correctly
- [ ] Uninstallation is clean (`brew uninstall sbv2srt`)

## Common Issues

### Build Dependencies

The formula uses Elixir/Erlang as build dependencies:
```ruby
depends_on "elixir" => :build
depends_on "erlang" => :build
```

This means users don't need Elixir installed to use the tool, only to build it.

### Network Access

Homebrew builds in a sandboxed environment with limited network access. The formula:
- Downloads dependencies during `mix deps.get`
- This is allowed during build phase
- The final escript is self-contained

### Testing

The formula includes a comprehensive test that:
- Creates a sample SBV file
- Runs the conversion
- Verifies the output format and content
- Ensures the tool works correctly

## Maintenance

### Updating Versions

For new releases:

1. Run the release script: `./scripts/prepare_release.sh 1.1.0`
2. Create the GitHub release
3. Update the formula: `./scripts/update_formula.sh 1.1.0`
4. Test the updated formula
5. Submit PR to homebrew-core (or update your tap)

### Security

- Keep dependencies updated
- Monitor for security advisories
- Test releases thoroughly before distribution

## Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Acceptable Formulae](https://docs.brew.sh/Acceptable-Formulae)
- [Contributing to Homebrew](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request)