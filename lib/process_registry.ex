defmodule DocsetGenerator.ViaTupleRegistry do
  def start_link(opts), do: Registry.start_link(opts)

  # the `:via` option expects a module that exports
  # `register_name/2`, `unregister_name/1`, `whereis_name/1` and `send/2`.
  def whereis_name(name), do: (apply(Registry, :whereis_name, [{__MODULE__, name}]))

  def register_name(name, pid),
    do: apply(Registry, :register_name, [{__MODULE__, name}, pid])

  def unregister_name(name),
    do: apply(Registry, :unregister_name, [{__MODULE__, name}])

  defdelegate send(dest, message), to: Registry
end
