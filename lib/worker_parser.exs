defmodule DocsetGenerator.WorkerParser do
  alias DocsetGenerator.Indexer
  alias DocsetGenerator.WorkerParser.LineAccumulator

  def start_link(filepath) do
    Task.start_link(__MODULE__, :parse_entries, [filepath])
  end

  def parse_entries(filepath) do
    line_acc = LineAccumulator.start_link()
    caller = self()

    File.Stream!(filepath)
    |> &LineAccumulator.add_line(line_acc, &1, caller)
    |> Stream.run()

    collect_all_entries(filepath)

    rescue
    err -> err |> Indexer.report_error(filepath)
  end

  def collect_all_entries(filepath) do
    receive do
      {:entry, entry} ->
        store_entry(entry, filepath)
        wait_for_entries(filepath)
      {:eol} ->
        report_done(filepath)
    end
  end

  def store_entry(entry, filepath) do
    Indexer.report_result(Map.put(entry, :filepath, filepath))
  end
end
