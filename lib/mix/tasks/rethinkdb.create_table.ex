defmodule Mix.Tasks.Rethinkdb.CreateTable do
  @moduledoc """
  Generate a Rethinkdb Resource file to keep tables 
  and also create the table in database

  mix rethinkdb.create_table User

  Creates a web/admin/survey.ex file.
  """
  use Mix.Task
  import Mix.Rethinkdb.Utils

  @filename "tables.exs" 

  def run(args) do
    parse_args(args)
    |> copy_file
  end

  defp copy_file(module) do
    dest_path = Path.join ~w(priv repo rethinkdb)
    dest_file_path = Path.join dest_path, @filename
    source = String.downcase(module)
    if not File.exists?(dest_path) do
      status_msg "creating", dest_file_path
      File.mkdir(dest_path)
    end

    if File.exists?(dest_file_path) do
      File.write! dest_file_path, "\n" <> source, [:append]
    else
      File.write! dest_file_path, source
    end
    status_msg "created", dest_file_path
  end

  defp parse_args([args] \\ nil) do
    if args == "" or is_atom(args) or args == nil do
      raise_with_help
    else
      args
    end
  end

  defp raise_with_help() do
    Mix.raise """
    mix rethinkdb.create_table expects a table name
        mix rethinkdb.create_table User
    """
  end

end
