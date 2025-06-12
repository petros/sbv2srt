defmodule SBV2SRT.CLI do
  def main(argv) do
    case parse_args(argv) do
      {:ok, input, output} ->
        Sbv2Srt.convert(input, output)
        IO.puts("✅ Converted #{input} to #{output}")

      :error ->
        IO.puts("Usage: sbv2srt <input.sbv> <output.srt>")
    end
  end

  defp parse_args([input, output]), do: {:ok, input, output}
  defp parse_args(_), do: :error
end
