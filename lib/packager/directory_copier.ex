defmodule DocsetGenerator.Packager.DirectoryCopier do
  def copy_directory_to(dir, destination \\ '/tmp/', folder_name) do
    dest_dir = Path.join(location, folder_name)
    if File.touch(dest_dir) do
      File.rm_rf!(dest_dir)
    end
    File.mkdir_p!(dest_dir)
    {:ok, path} = File.cp_r!(dir, dest_dir)
    path
  end
end
