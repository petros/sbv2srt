class Sbv2srt < Formula
  desc "Convert YouTube SBV subtitle files to SRT format"
  homepage "https://github.com/petros/sbv2srt"
  url "https://github.com/petros/sbv2srt/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "SHA256_CHECKSUM_HERE"
  license "MIT"
  head "https://github.com/petros/sbv2srt.git", branch: "main"

  depends_on "elixir" => :build

  def install
    ENV["MIX_ENV"] = "prod"
    ENV["HEX_HOME"] = buildpath/".hex"
    ENV["MIX_HOME"] = buildpath/".mix"
    ENV["MIX_ARCHIVES"] = buildpath/".mix/archives"

    system "mix", "local.hex", "--force", "--if-missing"
    system "mix", "local.rebar", "--force", "--if-missing"

    system "mix", "deps.get"
    system "mix", "compile"

    system "mix", "escript.build"

    bin.install "sbv2srt"
  end

  test do
    (testpath/"test.sbv").write <<~EOS
      0:00:01.000,0:00:04.000
      Hello, this is a test subtitle.

      0:00:05.500,0:00:08.200
      This should convert to SRT format.
    EOS

    system bin/"sbv2srt", "test.sbv", "test.srt"

    assert_predicate testpath/"test.srt", :exist?

    output = (testpath/"test.srt").read
    assert_match(/^1$/, output)
    assert_match(/^2$/, output)
    assert_match(/00:00:01,000 --> 00:00:04,000/, output)
    assert_match(/00:00:05,500 --> 00:00:08,200/, output)
    assert_match(/Hello, this is a test subtitle\./, output)
    assert_match(/This should convert to SRT format\./, output)
  end
end