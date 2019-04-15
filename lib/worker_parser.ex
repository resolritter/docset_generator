defmodule DocsetGenerator.WorkerParser do
  alias DocsetGenerator.WorkerParser.{LineAccumulator, EntryCollector}

  def start_link(filepath, parser_functions) do
    Task.start_link(__MODULE__, :parse_entries, [filepath, parser_functions])
  end

  @doc """
  The spawned EntryCollector will signalize when the task has ended back to the indexer.
  """
  def parse_entries(filepath, parser_functions) do
    {:ok, _} = EntryCollector.start_link(self(), filepath)
    {:ok, _} = LineAccumulator.start_link(filepath, parser_functions)

    File.stream!(filepath)
    |> Stream.each(&LineAccumulator.add_line(filepath, &1))
    |> Stream.run()
  end
end
