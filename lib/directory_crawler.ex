defmodule DocsetGenerator.DirectoryCrawler do
  use GenServer

  @impl GenServer
  def init(path) do
    { :ok, DirWalker.start_link(path, matching: ~r'\.html') }
  end

  def get_next_n(crawler, n) do
    GenServer.call(crawler, {:next_n, n})
  end

  @impl GenServer
  def handle_call({:next_n, n}, walker) do
    case DirWalker.next(walker, n) do
      {:ok, directories} -> {:ok, directories, walker}
      err -> terminate(err)
    end
  end
end
