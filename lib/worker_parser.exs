defmodule DocsetGenerator.WorkerParser do
  use Task
  alias DocsetGenerator.Indexer

  def start_link(filepath) do
    Task.start_link(__MODULE__, :run, [filepath])
  end

  def run(filepath) do
    filepath |> parse_index_entries
  end

  def parse_index_entries(filepath) do
    filepath
    |> File.Stream
    |> Stream.map &line_entry_regex(&1)
    |> Stream.reject &Kernel.is_nil
    |> store_entry filepath
    rescue
    e in File.Error -> e |> report_error(filepath)
  end

  def store_entry(entry, filepath) do
    Indexer.report_result(Map.put(entry, :filepath, filepath))
  end

  def report_error(error, filepath) do
    Indexer.report_error(error, "#{filepath} couldn't be read")
  end
end
