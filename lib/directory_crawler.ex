defmodule DocsetGenerator.DirectoryCrawler do
  alias DocsetGenerator.ViaTupleRegistry
  use GenServer

  def start_link(root),
    do: GenServer.start_link(__MODULE__, [root], name: via_tuple())

  @impl GenServer
  def init(root), do: DirWalker.start_link(root, matching: ~r'\.html')

  def via_tuple(), do: {:via, ViaTupleRegistry, {__MODULE__}}

  def get_next_n(n), do: GenServer.call(via_tuple(), {:next_n, n})

  @impl GenServer
  def handle_call({:next_n, n}, _from, walker) do
    {:reply, DirWalker.next(walker, n), walker}
  end
end
