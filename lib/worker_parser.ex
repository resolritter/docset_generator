defmodule DocsetGenerator.WorkerParser do
  alias DocsetGenerator.WorkerParser.{LineAccumulator, EntryCollector}

  def start_link(filepath) do
    Task.start_link(__MODULE__, :parse_entries, [filepath])
  end

  @doc """
  The spawned EntryCollector will signalize when the task has ended back to the indexer.
  """
  def parse_entries(filepath) do
    {:ok} = EntryCollector.start_link([self(), filepath])
    {:ok} = LineAccumulator.start_link([filepath])

    File.stream!(filepath)
    |> Stream.each(&LineAccumulator.add_line(filepath, &1))
    |> Stream.run()
  end
end
