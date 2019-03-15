defmodule DocsetGenerator.WorkerParser do
  alias DocsetGenerator.Indexer
  alias DocsetGenerator.WorkerParser.LineAccumulator

  def start_link(filepath) do
    Task.start_link(__MODULE__, :parse_entries, [filepath])
  end

  def parse_entries(filepath) do
    line_accumulator = LineAccumulator.start_link()
    
    File.Stream!(filepath)
    |> LineAccumulator.add_line_to(line_accumulator, self())
    |> Stream.run()

    collect_all_entries(filepath)

    rescue
    err -> err |> Indexer.report_error(filepath)
  end

  def collect_all_entries(filepath) do
    receive do
      {:entry, entry} ->
        store_entry(filepath)
        wait_for_entries(filepath)
      {:eol} ->
        report_done(filepath)
    end
  end

  def store_entry(entry, filepath) do
    Indexer.report_result(Map.put(entry, :filepath, filepath))
  end
end

defmodule DocsetGenerator.WorkerParser.LineAccumulator do
  def start_link() do
    Agent.start_link(%{:lines_read => 0, :acc => "" })
  end

  def add_line_to(line, line_accumulator, caller) do
    case line do
      line ->
        Agent.update(self(), fn %{:lines_read => lr, :acc => acc} ->
          accumulated_string = acc <> line
          case attempt_match_entry(accumulated_string) do
            entry ->
              send(caller, entry)
              %{:lines_read => lr + 1, :acc => ""}
            nil ->
              %{:lines_read => lr + 1, :acc => accumulated_string}
          end
        end)
      :ok -> send(caller, :eol)
    end
  end
end
