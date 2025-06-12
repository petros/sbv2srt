defmodule Sbv2Srt do
  def convert(input_path, output_path) do
    input_path
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.chunk_by(&(&1 != ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.with_index(1)
    |> Enum.map(fn {chunk, index} ->
      [timecode | lines] = chunk
      [start_ts, end_ts] = String.split(timecode, ",")
      start_ts = format_time(start_ts)
      end_ts = format_time(end_ts)

      [Integer.to_string(index), "#{start_ts} --> #{end_ts}" | lines] ++ [""]
    end)
    |> List.flatten()
    |> Enum.join("\n")
    |> then(&File.write!(output_path, &1))
  end

  defp format_time(ts) do
    ts
    |> String.pad_leading(8, "0")
    |> String.replace(".", ",")
    |> then(fn t -> if String.length(t) == 8, do: "00:" <> t, else: t end)
  end
end


