defmodule DocsetGenerator.Indexer do
  use Agent
  alias DocsetGenerator.{DirectoryCrawler, WorkerParser, Indexer}

  #
  # Init methods
  #
  def start_indexing(root) do
    Agent.start_link(&index_root(root), name: __MODULE__)
  end

  defp index_root(root) do
    children = [
      {DirectoryCrawler, [root], name: DocsetGenerator.DirectoryCrawler},
      {Task.Supervisor, name: Indexer.WorkerSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)

    %{
      :entries => [],
      :errors => [],
      :workers => [],
      :filepath_buffer => [],
      :directory_crawling_done => false
    }
  end

  def new_entry(entry) do
    Agent.update(__MODULE__, fn state ->
      Map.update!(state, :entries, [entry | state[:entries]])
    end)
  end

  def new_filepath(filepath) do
    Agent.update(__MODULE__, fn state ->
      schedule_work(filepath, state)
    end)
  end

  def task_done(task_pid) do
    Agent.update(
      __MODULE__,
      fn state ->
        Map.update!(
          state,
          :workers,
          &(&1 |> Enum.reject(fn {pid, _} -> pid == task_pid end))
        )
      end
    )
  end

  def report_error(error, filepath) do
    Agent.update(__MODULE__, fn state ->
      Map.update!(
        state,
        :errors,
        &[%{:error => error, :filepath => filepath} | &1]
      )
    end)
  end

  def report_directory_crawling_finished() do

  end

  defp discovery_work_finished(final_state) do
    final_state
    |> await_remaining_jobs()
    |> persist_database_entries()

    final_state
  end

  defp await_remaining_jobs(final_state) do
    final_state[:workers]
    |> Enum.map(&Task.await(&1))
    |> Map.update!(:workers, &[])
  end


  defp persist_database_entries(final_state) do

  end

  defp schedule_work(filepath, state) do
    new_state =
      if length(state[:workers]) < 4 do
        Map.update!(
          state,
          :workers,
          [
            # pid
            Task.Supervisor.async(
              Indexer.WorkerSupervisor,
              &WorkerParser.start_link(filepath)
            )
            |> elem(1)
            | &1
          ]
        )
      else
        Map.update!(state, :filepath_buffer, &[filepath | &1])
      end

    if Enum.empty?(new_state[:filepath_buffer]) &&
         new_state[:directory_crawling_done] do
      Indexer.discovery_work_finished(new_state)
    else
      new_state
    end
  end
end
