defmodule DocsetGenerator.Packager.DirectoryCopier do
  alias DocsetGenerator.Packager

  def copy_directory_to(%Packager{
        :destination => destination,
        :docset_name => docset_name,
        :doc_directory => doc_directory
      }) do
    unless File.dir?(doc_directory) do
      IO.puts('"#{doc_directory}" is no longer a valid directory.')
      exit(:ERR_doc_directory_missing)
    end

    dest_dir = Path.join(destination, docset_name)

    if File.exists?(dest_dir), do: File.rm_rf!(dest_dir)

    File.mkdir_p!(dest_dir)
    File.cp_r!(doc_directory, dest_dir)
  end
end
