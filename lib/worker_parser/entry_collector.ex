defmodule DocsetGenerator.WorkerParser.EntryCollector do
  defstruct [:parent_pid, :filepath, :entries]
  alias DocsetGenerator.WorkerParser.EntryCollector
  use Agent

  def start_link(parent_pid, filepath) do
    Agent.start_link(
      fn ->
        %EntryCollector{
          :parent_pid => parent_pid,
          :filepath => filepath,
          :entries => []
        }
      end,
      name: generate_module_name(filepath)
    )
  end

  defp generate_module_name(filepath) do
    filepath <> "--collector"
  end

  def collect_new_entry(filepath, new_entry) do
    Agent.update(generate_module_name(filepath), fn state ->
      state
      |> Map.update!(:entries, &[new_entry | &1])
    end)
  end

  def stop_collecting(filepath) do
    Indexer.task_done(Agent.get(generate_module_name(filepath)))
  end
end
