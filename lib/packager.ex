defmodule DocsetGenerator.Packager do
  defstruct [:doc_directory, :docset_name, :destination, :parser]

  def package(final_indexer_state) do
    exit(final_indexer_state)
  end

  def show_packaging_result(packager) do
    exit(packager)
  end
end
