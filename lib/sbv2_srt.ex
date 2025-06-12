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
    # Handle both "H:MM:SS.mmm" and "M:SS.mmm" formats
    ts
    |> String.replace(".", ",")
    |> then(fn time_str ->
      case String.split(time_str, ":") do
        [minutes, seconds] ->
          # Format: "M:SS,mmm" -> "00:0M:SS,mmm"
          padded_minutes = String.pad_leading(minutes, 2, "0")
          "00:#{padded_minutes}:#{seconds}"
        
        [hours, minutes, seconds] ->
          # Format: "H:MM:SS,mmm" -> "0H:MM:SS,mmm"
          padded_hours = String.pad_leading(hours, 2, "0")
          "#{padded_hours}:#{minutes}:#{seconds}"
        
        _ ->
          time_str
      end
    end)
  end
end


