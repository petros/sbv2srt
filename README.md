# SBV2SRT

A command-line utility for converting YouTube SBV subtitle files to SRT format.

## Description

SBV2SRT is a simple, fast CLI tool that converts YouTube's `.sbv` subtitle format to the more widely supported `.srt` format. It handles timestamp conversion and formatting to ensure compatibility with most video players and subtitle editors.

## Features

- 🚀 Fast conversion of SBV to SRT format
- 📝 Proper timestamp formatting (HH:MM:SS,mmm format)
- 🎯 Simple command-line interface
- 📦 Standalone binary - no Elixir/Erlang runtime required
- 🔧 Cross-platform support (macOS, Linux, Windows)

## Installation

### Option 1: Homebrew (macOS/Linux) - Recommended

```bash
brew install sbv2srt
```

### Option 2: Download Pre-built Binary

Download the latest binary for your platform from the releases page:

- **macOS**: `sbv2srt_macos`
- **Linux**: `sbv2srt_linux`
- **Windows**: `sbv2srt_windows.exe`

Make the binary executable (macOS/Linux):
```bash
chmod +x sbv2srt_macos
```

### Option 3: Build from Source

If you have Elixir installed, you can build from source:

```bash
git clone <repository-url>
cd sbv2srt
mix deps.get
mix escript.build
```

This creates an `sbv2srt` escript that requires Erlang/Elixir to be installed on the target system.

You can then run it with:
```bash
./sbv2srt input.sbv output.srt
```

### Option 4: Build Standalone Binary

To build cross-platform standalone binaries (requires Zig 0.14.0, xz, and 7z):

```bash
# Ensure you have Zig 0.14.0 (see Prerequisites section above)
zig version  # Must show 0.14.0

# Build for all platforms
MIX_ENV=prod mix release

# Build for specific platform (faster)
BURRITO_TARGET=macos MIX_ENV=prod mix release
BURRITO_TARGET=linux MIX_ENV=prod mix release
BURRITO_TARGET=windows MIX_ENV=prod mix release
```

Binaries will be created in the `burrito_out/` directory.

**Troubleshooting**:
- If you get "Zig version does not match", ensure you have exactly Zig 0.14.0
- If builds fail, consider using the escript option instead
- For development, the escript is often more convenient

## Usage

### Basic Usage

```bash
sbv2srt input.sbv output.srt
```

### Examples

Convert a YouTube subtitle file:
```bash
./sbv2srt_macos "My Video.sbv" "My Video.srt"
```

Batch conversion with shell scripting:
```bash
# Convert all SBV files in current directory
for file in *.sbv; do
    ./sbv2srt_macos "$file" "${file%.sbv}.srt"
done
```

### File Format

**Input (SBV format):**
```
0:00:01.000,0:00:04.000
Hello, welcome to this video.

0:00:05.500,0:00:08.200
This is how SBV format works.
```

**Output (SRT format):**
```
1
00:00:01,000 --> 00:00:04,000
Hello, welcome to this video.

2
00:00:05,500 --> 00:00:08,200
This is how SBV format works.
```

## Error Handling

If you encounter issues:

- **File not found**: Ensure the input file path is correct
- **Permission denied**: Make sure the binary has execute permissions
- **Invalid format**: Verify the input file is in valid SBV format

## Development

### Prerequisites

- Elixir 1.18+ with OTP 27+
- For building standalone binaries (production builds only):
  - Zig 0.14.0 (**exactly this version** - 0.14.1 will NOT work)
  - xz command-line tool
  - 7z (for Windows builds)

**Note**: For development and escript builds, you only need Elixir. The additional tools are only required for creating standalone cross-platform binaries.

#### Why Zig 0.14.0 Exactly?

Burrito has a strict version check that only accepts Zig 0.14.0. This is because:
- Zig is still pre-1.0 and each minor version can have breaking changes
- Burrito's wrapper code is written in Zig and depends on specific APIs
- Different Zig versions can produce incompatible binaries

#### Installing Zig 0.14.0

**Option 1: Using asdf (Recommended)**
```bash
# Install asdf zig plugin
asdf plugin add zig

# Install Zig 0.14.0
asdf install zig 0.14.0

# Set it for this project
asdf local zig 0.14.0  # Creates .tool-versions file

# If you have homebrew zig installed, unlink it to avoid conflicts
brew unlink zig  # Only needed if you have homebrew zig

# Verify
zig version  # Should show 0.14.0
```

**Troubleshooting asdf/PATH Issues:**
- If `zig version` still shows 0.14.1, check that asdf shims come before homebrew in PATH
- Run `which zig` - it should show `/Users/[username]/.asdf/shims/zig`, not `/opt/homebrew/bin/zig`
- If homebrew version takes precedence, run `brew unlink zig` to remove the conflict
- Restart your terminal or run `asdf reshim zig` if changes don't take effect

**Option 2: Manual Download**
```bash
# macOS (Apple Silicon)
curl -L "https://ziglang.org/download/0.14.0/zig-macos-aarch64-0.14.0.tar.xz" -o zig-0.14.0.tar.xz
# macOS (Intel)
curl -L "https://ziglang.org/download/0.14.0/zig-macos-x86_64-0.14.0.tar.xz" -o zig-0.14.0.tar.xz
# Linux
curl -L "https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz" -o zig-0.14.0.tar.xz

tar -xf zig-0.14.0.tar.xz
export PATH="$(pwd)/zig-*-0.14.0:$PATH"
zig version  # Should show 0.14.0
```

### Setup

```bash
git clone <repository-url>
cd sbv2srt
mix deps.get
```

### Running Tests

```bash
mix test
```

### Development Commands

```bash
# Run in development
mix run -e "SBV2SRT.CLI.main([\"input.sbv\", \"output.srt\"])"

# Build escript (requires Elixir on target)
mix escript.build
./sbv2srt input.sbv output.srt

# Build standalone binary (requires Zig 0.14.0, xz, 7z)
MIX_ENV=prod mix release
```

### Technical Details

### Architecture

- **CLI Module**: `SBV2SRT.CLI` - Command-line interface and argument parsing
- **Converter Module**: `Sbv2Srt` - Core conversion logic
- **Application Module**: `SBV2SRT.Application` - Application startup for standalone binaries (production only)

### Development vs Production

- **Development**: The CLI runs directly without the Application module, allowing for easy testing and development
- **Production**: The Application module handles startup for standalone binaries created by Burrito
- **Escript**: Works in both modes and provides a middle ground - distributable but requires Elixir runtime

### Dependencies

- `burrito` - For creating standalone cross-platform binaries
- Standard Elixir/OTP libraries only

### Build System

The project uses Burrito to create self-contained binaries that include:
- Compiled BEAM code
- Erlang Runtime System (ERTS)
- All dependencies

This eliminates the need for users to have Elixir/Erlang installed.

## Distribution

### Homebrew

This package is available via Homebrew. To distribute a new version:

1. **Create a release**:
   ```bash
   ./scripts/prepare_release.sh 1.0.0
   ```

2. **Create GitHub release** with the tagged version

3. **Update Homebrew formula** with new version and SHA256 checksum

See `HOMEBREW_DISTRIBUTION.md` for detailed instructions.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

### v0.1.0
- Initial release
- Basic SBV to SRT conversion
- Cross-platform standalone binaries
- Command-line interface

## Support

If you encounter any issues or have questions:

1. Check the error message for common issues
2. Verify file formats and permissions
3. Open an issue on the repository with:
   - Your operating system
   - The command you ran
   - The error message
   - Sample input file (if possible)