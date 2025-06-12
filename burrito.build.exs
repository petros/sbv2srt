import Burrito.Builder

defmodule Sbv2SrtRelease do
  use Burrito.Builder

  def releases do
    [
      release(
        name: "sbv2srt",
        version: "0.1.0",
        targets: [
          target("macos_arm64"),
          target("macos_x86_64"),
          target("linux_x86_64")
        ]
      )
    ]
  end
end