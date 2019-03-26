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
    { :ok, DirWalker.next(walker, n), walker }
  end
end
