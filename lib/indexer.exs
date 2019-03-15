defmodule DocsetGenerator.Indexer do
  use GenServer
  alias DocsetGenerator.DirectoryCrawler

  def index(dir) do
    GenServer.start_link(__MODULE__, dir, name: __MODULE__)
  end

  @impl GenServer
  def init(dir) do
    children = [
      { DirectoryCrawler, dir, name: DocsetGenerator.DirectoryCrawler },
      { Task.Supervisor, name: DocsetGenerator.WorkerSupervisor }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)

    {:ok, %{:entries: [], :errors: []}}
  end

  def report_result(entry) do
    GenServer.call(__MODULE__, {:report_result, entry})
  end

  def report_error(error, filepath) do
    GenServer.call(__MODULE__, {:report_result, error, filepath})
  end

  @impl GenServer
  def handle_call(%{:report_result, entry}, state) do
    new_state = state |> Kernel.put_in(state[:entries], entry)
    {:ok, new_state, new_state}
  end

  @impl GenServer
  def handle_info({:finish}, state) do
    await_remaining_tasks
    persist_results
    {:noreply}
  end

  @impl GenServer
  def handle_cast({:report_error, error, filepath}, state) do
    new_state = state |> Map.put_new(entry)
    {:ok, new_state, new_state}
  end
end
