defmodule DocsetGenerator.DirectoryCrawler do
  alias DocsetGenerator.ProcessRegistry
  use GenServer

  def start_link(root),
    do: GenServer.start_link(__MODULE__, [root], name: via_tuple())

  @impl GenServer
  def init(root) do
    {:ok, DirWalker.start_link(root, matching: ~r'\.html')}
  end

  def via_tuple(), do: {:via, ProcessRegistry, {__MODULE__}}

  def get_next_n(n), do: GenServer.call(via_tuple(), {:next_n, n})

  @impl GenServer
  def handle_call({:next_n, n}, _from, walker) do
    {_, directories} = DirWalker.next(walker, n)
    {:reply, directories, walker}
  end
end
