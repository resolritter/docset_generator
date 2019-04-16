defmodule DocsetGenerator do
  alias DocsetGenerator.{Packager, Indexer}

  @doc """
  CLI entrypoint. Validates arguments and starts searching if validation passes.
  """
  def main(args \\ []) do
    args
    |> args_valid?
    |> Indexer.start_link()
  end

  defp args_valid?(args) do
    {switches, argv, _} =
      args
      |> OptionParser.parse(
        switches: [
          destination: :string,
          name: :string,
          help: nil
        ]
      )

    if switches[:help] do
      IO.puts("""
      Usage: docset-generator [--name] doc_directory [destination]

      Required:
      * doc_directory : The folder where ExDoc has generated the documentation to.

      Optional:
      * --name : Define a custom name for the docset. Default: decided by folder name.
      * destination : Where to output the generated docset folder to. Default: to the same folder this program was called from.
      """)

      exit(:normal)
    end

    argv_len = length(argv)

    if argv_len < 1 do
      exit(IO.puts("Missing required argument: doc_directory."))
    end

    [doc_directory | optional_args] = argv

    unless File.dir?(doc_directory) do
      IO.puts("Argument provided is not a directory: '#{doc_directory}'")
      Kernel.exit(:not_directory)
    end

    docset_name =
      if switches[:name],
        do: switches[:name],
        else: generate_package_name(doc_directory)

    destination =
      if Enum.empty?(optional_args),
        do: Path.join(File.cwd!(), generate_package_name(doc_directory)),
        else: List.first(optional_args)

    # Kernel.exit({doc_directory, docset_name, destination})

    # TODO make the parser also configurable through CLI, by default it only parses ExDoc
    %Packager{
      :doc_directory => doc_directory,
      :docset_name => docset_name,
      :destination => destination,
      :parser => DocsetGenerator.WorkerParser.RegexMatcher.Elixir
    }
  end

  defp generate_package_name(doc_directory) do
    path_pieces = Path.split(doc_directory)
    # "../phoenix/doc" -> ["..", "phoenix", "doc"], phoenix is at len - 2
    at_lib_name = max(0, length(path_pieces) - 2)

    path_pieces
    |> Enum.reduce_while(0, fn cur, i ->
      if i == at_lib_name, do: {:halt, cur}, else: {:cont, i + 1}
    end)
  end

  def build_docset(final_indexer_state) do
    final_indexer_state
    |> Packager.package()
    |> Packager.show_packaging_results()
  end
end
