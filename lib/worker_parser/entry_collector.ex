defmodule DocsetGenerator.WorkerParser.EntryCollector do
  alias DocsetGenerator.ViaTupleRegistry
  alias DocsetGenerator.Indexer
  use Agent

  def start_link(task_pid, filepath) do
    Agent.start_link(
      fn ->
        task_pid
      end,
      name: via_tuple(filepath)
    )
  end

  def via_tuple(filepath),
    do: {:via, ViaTupleRegistry, {filepath <> "--collector"}}

  def collect_new_entry(filepath, new_entry) do
    Indexer.new_entry(Map.put_new(new_entry, :filepath, filepath))
  end

  def stop_collecting(filepath) do
    via_tuple(filepath)
    |> Agent.get(& &1)
    |> Indexer.task_done()
  end
end
