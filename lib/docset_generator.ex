defmodule DocsetGenerator do
  alias DocsetGenerator.{Supervisor, Packager}

  def main(args \\ []) do
    args
    |> args_valid?
    |> start_dir_search
  end

  defp start_dir_search(dir) do
    Indexer.index(dir)
  end

  defp args_valid?([dir | other_args]) do
    unless Enum.empty?(other_args) do
      IO.puts(
        "Provide a single argument, which is the directory of the generated doc path"
      )

      Kernel.exit(:too_many_arguments)
    end

    unless File.dir?(dir) do
      IO.puts("Argument provided is not a directory: '#{dir}'")
      Kernel.exit(:not_directory)
    end
  end

  defp final_step_build_docset(final_indexer_state) do
    final_indexer_state
    |> Packager.package()
    |> Packager.show_packaging_results()
  end
end
