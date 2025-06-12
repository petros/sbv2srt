class Sbv2srt < Formula
  desc "Convert YouTube SBV subtitle files to SRT format"
  homepage "https://github.com/USERNAME/sbv2srt"
  url "https://github.com/USERNAME/sbv2srt/archive/v0.1.0.tar.gz"
  sha256 "SHA256_CHECKSUM_HERE"
  license "MIT"

  depends_on "elixir" => :build
  depends_on "erlang" => :build

  def install
    # Set up Elixir environment
    system "mix", "local.hex", "--force"
    system "mix", "local.rebar", "--force"
    
    # Get dependencies and compile
    system "mix", "deps.get"
    system "mix", "compile"
    
    # Build escript
    system "mix", "escript.build"
    
    # Install the binary
    bin.install "sbv2srt"
  end

  test do
    # Create a test SBV file
    (testpath/"test.sbv").write <<~EOS
      0:00:01.000,0:00:04.000
      Hello, this is a test subtitle.

      0:00:05.500,0:00:08.200
      This should convert to SRT format.
    EOS

    # Run the conversion
    system bin/"sbv2srt", "test.sbv", "test.srt"
    
    # Check that output file was created
    assert_predicate testpath/"test.srt", :exist?
    
    # Verify the output format
    output = (testpath/"test.srt").read
    assert_match(/^1$/, output)
    assert_match(/00:00:01,000 --> 00:00:04,000/, output)
    assert_match(/Hello, this is a test subtitle\./, output)
    assert_match(/^2$/, output)
    assert_match(/00:00:05,500 --> 00:00:08,200/, output)
    assert_match(/This should convert to SRT format\./, output)
  end
end