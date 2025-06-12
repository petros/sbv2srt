defmodule Sbv2SrtTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  describe "convert/2" do
    test "converts simple SBV to SRT format" do
      input_content = """
      0:00:01.000,0:00:04.000
      Hello, this is a test subtitle.

      0:00:05.500,0:00:08.200
      This should convert to SRT format.
      """

      expected_output = """
      1
      00:00:01,000 --> 00:00:04,000
      Hello, this is a test subtitle.

      2
      00:00:05,500 --> 00:00:08,200
      This should convert to SRT format.
      """

      input_file = "test_input.sbv"
      output_file = "test_output.srt"

      try do
        File.write!(input_file, input_content)
        Sbv2Srt.convert(input_file, output_file)
        
        assert File.exists?(output_file)
        actual_output = File.read!(output_file)
        assert String.trim(actual_output) == String.trim(expected_output)
      after
        File.rm(input_file)
        File.rm(output_file)
      end
    end

    test "handles multi-line subtitles" do
      input_content = """
      0:00:01.000,0:00:04.000
      First line of subtitle
      Second line of subtitle

      0:00:05.500,0:00:08.200
      Another subtitle
      With multiple lines
      """

      expected_output = """
      1
      00:00:01,000 --> 00:00:04,000
      First line of subtitle
      Second line of subtitle

      2
      00:00:05,500 --> 00:00:08,200
      Another subtitle
      With multiple lines
      """

      input_file = "test_multiline.sbv"
      output_file = "test_multiline.srt"

      try do
        File.write!(input_file, input_content)
        Sbv2Srt.convert(input_file, output_file)
        
        actual_output = File.read!(output_file)
        assert String.trim(actual_output) == String.trim(expected_output)
      after
        File.rm(input_file)
        File.rm(output_file)
      end
    end

    test "formats timestamps correctly" do
      input_content = """
      0:00:01.500,0:00:04.250
      Test timestamp formatting.
      """

      expected_output = """
      1
      00:00:01,500 --> 00:00:04,250
      Test timestamp formatting.
      """

      input_file = "test_timestamp.sbv"
      output_file = "test_timestamp.srt"

      try do
        File.write!(input_file, input_content)
        Sbv2Srt.convert(input_file, output_file)
        
        actual_output = File.read!(output_file)
        assert String.trim(actual_output) == String.trim(expected_output)
      after
        File.rm(input_file)
        File.rm(output_file)
      end
    end

    test "handles empty subtitle blocks" do
      input_content = """
      0:00:01.000,0:00:04.000
      First subtitle

      0:00:10.000,0:00:12.000
      Second subtitle after gap
      """

      input_file = "test_gaps.sbv"
      output_file = "test_gaps.srt"

      try do
        File.write!(input_file, input_content)
        Sbv2Srt.convert(input_file, output_file)
        
        actual_output = File.read!(output_file)
        assert actual_output =~ "1\n00:00:01,000 --> 00:00:04,000"
        assert actual_output =~ "2\n00:00:10,000 --> 00:00:12,000"
      after
        File.rm(input_file)
        File.rm(output_file)
      end
    end
  end

  describe "CLI" do
    test "shows usage when called without arguments" do
      output = capture_io(fn ->
        SBV2SRT.CLI.main([])
      end)
      
      assert output =~ "Usage: sbv2srt <input.sbv> <output.srt>"
    end

    test "shows usage when called with wrong number of arguments" do
      output = capture_io(fn ->
        SBV2SRT.CLI.main(["only_one_arg"])
      end)
      
      assert output =~ "Usage: sbv2srt <input.sbv> <output.srt>"
    end

    test "converts file when called with correct arguments" do
      input_content = """
      0:00:01.000,0:00:04.000
      CLI test subtitle.
      """

      input_file = "cli_test.sbv"
      output_file = "cli_test.srt"

      try do
        File.write!(input_file, input_content)
        
        output = capture_io(fn ->
          SBV2SRT.CLI.main([input_file, output_file])
        end)
        
        assert output =~ "✅ Converted #{input_file} to #{output_file}"
        assert File.exists?(output_file)
        
        actual_output = File.read!(output_file)
        assert actual_output =~ "1\n00:00:01,000 --> 00:00:04,000"
        assert actual_output =~ "CLI test subtitle."
      after
        File.rm(input_file)
        File.rm(output_file)
      end
    end
  end
end
