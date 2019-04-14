defmodule DocsetGenerator.Indexer do
  alias DocsetGenerator.{DirectoryCrawler, WorkerParser, Packager}
  use Agent

  @worker_pool_amount 4
  def start_indexing(root) do
    Agent.start_link(fn -> index_root(root) end, name: __MODULE__)
    request_work()
  end

  defp index_root(%Packager{:doc_directory => root} = packager) do
    children = [
      {DirectoryCrawler, [root], name: :files_supervisor},
      {Task.Supervisor, name: :worker_supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)

    %{
      :entries => [],
      :errors => [],
      :workers => [],
      :filepath_buffer => [],
      :directory_crawling_done => false,
      :packager => packager
    }
  end

  defp request_work() do
    :files_supervisor
    |> DirectoryCrawler.get_next_n(@worker_pool_amount)
    |> Enum.map(&new_filepath(&1))
  end

  def new_entry(entry) do
    Agent.update(__MODULE__, fn state ->
      Map.update!(state, :entries, &[entry | &1])
    end)
  end

  def new_filepath(:ok) do
    Agent.update(__MODULE__, fn state ->
      Map.update!(
        state,
        :directory_crawling_done,
        fn -> true end
      )
    end)
  end

  def new_filepath(filepath) do
    Agent.update(__MODULE__, fn state ->
      schedule_work(filepath, state)
    end)
  end

  @doc """
  Informs to the indexer that a task has been done, thus it can remove the task pid from the list of workers to free up space for a waiting filepath from the buffer.
  """
  def task_done(done_task_pid) do
    Agent.update(
      __MODULE__,
      fn state ->
        schedule_work(
          Map.update!(
            state,
            :workers,
            &Enum.reject(&1, fn {worker_pid, _} ->
              worker_pid == done_task_pid
            end)
          )
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

  # Waits for the workers to finish and calls the action build the docset with all the accumulated entries.
  defp indexing_done(final_state) do
    final_state
    |> Map.update!(:workers, fn worker_list ->
      Enum.map(worker_list, &Task.await(&1))
    end)
    |> DocsetGenerator.final_step_build_docset()
  end

  defp spawn_single_worker(filepath) do
    {:ok, pid} =
      Task.Supervisor.async(
        :indexer_workersupervisor,
        fn -> WorkerParser.start_link(filepath) end
      )

    pid
  end

  # Attempts to use any buffered filepath discovered from the crawler.
  # - Updates the state by scheduling work to the first buffered filepath if it's there.
  # - Returns the state if there's no filepath in the buffer to be processed.
  defp schedule_work(state) do
    case state[:filepath_buffer] do
      [buffered | remaining] ->
        schedule_work(
          state
          |> Map.update!(:filepath_buffer, fn -> remaining or [] end),
          buffered
        )

      _ ->
        state
    end
  end

  # Attempts to schedule work for a new filepath if the pool is open.
  # Otherwise, pushes the filepath into the buffer for further processing.
  defp schedule_work(state, filepath) do
    next_state =
      if length(state[:workers]) < @worker_pool_amount do
        Map.update!(
          state,
          :workers,
          &[
            spawn_single_worker(filepath) | &1
          ]
        )
      else
        Map.update!(state, :filepath_buffer, &[filepath | &1])
      end

    if Enum.empty?(next_state[:filepath_buffer]) &&
         next_state[:directory_crawling_done] do
      indexing_done(next_state)
    else
      next_state
    end
  end
end
