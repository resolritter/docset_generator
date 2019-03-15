defmodule DocsetGenerator.Indexer do
  # TODO can it be an Agent instead?
  use GenServer
  alias DocsetGenerator.{DirectoryCrawler, WorkerParser, Indexer}

  def index(root) do
    GenServer.start_link(__MODULE__, root, name: __MODULE__)
  end

  @impl GenServer
  def init(root) do
    children = [
      {DirectoryCrawler, [root], name: DocsetGenerator.DirectoryCrawler},
      {Task.Supervisor, name: DocsetGenerator.WorkerSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)

    {:ok,
     %{
       :entries => [],
       :errors => [],
       :workers => [],
       :filepath_buffer => [],
       :directory_crawler_done => false
     }}
  end

  def report_result(entry) do
    GenServer.call(__MODULE__, {:report_result, entry})
  end

  def report_error(error, filepath) do
    GenServer.call(__MODULE__, {:report_result, error, filepath})
  end

  @impl GenServer
  def handle_call({:report_result, entry}, state) do
    {:ok, nil, Map.update(state, :entries, &[entry | &1])}
  end

  defp schedule_work(filepath, state) do
    if length(state[:workers]) < 4 do
      Map.update!(
        state,
        :workers,
        &[
          Task.Supervisor.async(
            MyApp.TaskSupervisor,
            &WorkerParser.start_link(filepath)
          )
          | &1
        ]
      )
    else
      Map.update!(state, :filepath_buffer, &[filepath | &1])
    end
  end

  @impl GenServer
  def handle_call({:filepath, filepath}, state) do
    {:ok, nil, schedule_work(filepath, state)}
  end

  @impl GenServer
  def handle_info({:task_done}, state) do
    [next_filepath | remaining] = state[:filepath_buffer]
    next_state = Map.update!(state, :filepath_buffer, &remaining)
    {:ok, schedule_work(next_filepath, next_state)}
  end

  @impl GenServer
  def handle_info({:directory_crawler_done}, state) do
    {:ok, Map.update!(state, :directory_crawler_done, true)}
  end

  @impl GenServer
  def handle_call({:report_error, error, filepath}, state) do
    # TODO format error message nicely
    {:ok, Map.update!(state, :errors, &[ error | &1 ])}
  end
end
