defmodule DocsetGenerator.DirectoryCrawler do
  use GenServer

  def start_link(root), do: GenServer.start_link(__MODULE__, [root], name: {:global, server_name()})

  def server_name(), do: __MODULE__

  @impl GenServer
  def init(root) do
    { :ok, DirWalker.start_link(root, matching: ~r'\.html') }
  end

  def get_next_n(crawler, n) do
    GenServer.call(crawler, {:next_n, n})
  end

  @impl GenServer
  def handle_call({:next_n, n}, _from, walker) do
    {_, directories} = DirWalker.next(walker, n)
    {:reply, directories, walker}
  end
end
