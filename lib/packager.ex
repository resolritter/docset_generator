defmodule DocsetGenerator.Packager do
  defstruct [:doc_directory, :docset_name, :destination, :parser]

  def package() do
  end

  def show_packaging_result(packager) do
    exit(packager)
  end
end
