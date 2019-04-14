defmodule DocsetGenerator.WorkerParser do
  alias DocsetGenerator.Indexer
  alias DocsetGenerator.WorkerParser.{LineAccumulator, EntryCollector}

  def start_link(filepath) do
    Task.start_link(__MODULE__, :parse_entries, [filepath])
  end

  def parse_entries(filepath) do
    {:ok, collector} = EntryCollector.start_link([self(), filepath])
    {:ok, line_acc} = LineAccumulator.start_link([filepath, collector])

    File.stream!(filepath)
    |> Stream.each(&LineAccumulator.add_line(&1, line_acc))
    |> Stream.run()
  end
end
