defmodule DocsetGenerator do
  alias DocsetGenerator.Packager

  def main(args \\ []) do
    args
    |> args_valid?
    |> start_dir_search()
  end

  defp start_dir_search(dir) do
    Indexer.index(%Packager{})
  end

  defp args_valid?([dir | other_args]) do
    {opts, word, b} =
      args
      |> OptionParser.parse(
        switches: [
          docs_source: :string,
          destination: :string,
          docset_name: :string
        ]
      )

    unless File.dir?(dir) do
      IO.puts("Argument provided is not a directory: '#{dir}'")
      Kernel.exit(:not_directory)
    end

    Kernel.exit(IO.puts({opts, word, b}))

    {opts, List.to_string(word)}
  end

  defp generate_package_information(final_indexer_state) do
  end

  defp final_step_build_docset(final_indexer_state) do
    final_indexer_state
    |> Packager.package()
    |> Packager.show_packaging_results()
  end
end
