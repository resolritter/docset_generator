defmodule DocsetGenerator.WorkerParser.EntryCollector do
  alias DocsetGenerator.Indexer
  use Agent

  def start_link(task_pid, filepath) do
    Agent.start_link(
      fn ->
        task_pid
      end,
      name: agent_name(filepath)
    )
  end

  def agent_name(filepath), do: {:global, filepath <> "--collector"}

  def collect_new_entry(filepath, new_entry) do
    Indexer.new_entry(Map.put_new(new_entry, :filepath, filepath))
  end

  def stop_collecting(filepath) do
    agent_name(filepath)
    |> Agent.get(&(&1))
    |> Indexer.task_done()
  end
end
