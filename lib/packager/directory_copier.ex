defmodule DocsetGenerator.Packager.DirectoryCopier do
  alias DocsetGenerator.Packager

  def copy_directory_to(%Packager{
        :destination => destination,
        :docset_name => docset_name,
        :docs_source => docs_source
      }) do
    unless File.dir?(docs_source) do
      IO.puts(:standard_error, '"#{docs_source}" is no longer a valid directory.')
      Kernel.exit(:ERR_docs_source_missing)
    end

    dest_dir = Path.join(destination, docset_name)

    if File.touch(dest_dir), do: File.rm_rf!(dest_dir)

    File.mkdir_p!(dest_dir)
    {:ok, path} = File.cp_r!(docs_source, dest_dir)

    path
  end
end
