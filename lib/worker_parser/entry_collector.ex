defmodule DocsetGenerator.WorkerParser.EntryCollector do
  defstruct [:task_pid, :filepath, :entries]
  alias DocsetGenerator.WorkerParser.EntryCollector
  use Agent

  def start_link(task_pid, filepath) do
    Agent.start_link(
      fn ->
        %EntryCollector{
          :task_pid => task_pid,
          :entries => []
        }
      end,
      name: agent_name(filepath)
    )
  end

  defp agent_name(filepath), do: {:global, filepath <> "--collector"}

  def collect_new_entry(filepath, new_entry) do
    Agent.update(agent_name(filepath), fn state ->
      state
      |> Map.update!(:entries, &[new_entry | &1])
    end)
  end

  def stop_collecting(filepath) do
    Indexer.task_done(Agent.get(agent_name(filepath))[:task_pid])
  end
end
