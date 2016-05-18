defmodule Mix.Tasks.Rethinkdb.Migrate do
  use Mix.Task
  import RethinkDB.Query
  require Logger
  alias Chatty.Repo 
  require IEx
  alias Mix.Rethinkdb.Utils

  @filename "tables.exs" 

  def run(_args) do
    create_tables
  end

  def create_tables() do
    ensure_started(Repo)
    tables = get_table_list 
    Enum.each(tables, fn(table_name) ->
      query = table_list
        |> contains(table_name)
        |> branch(%{data: %{}}, do_r(fn -> table_create(table_name) end))
      r = Repo.run(query)
      case Map.has_key?(r.data, "tables_created") do
        true ->
          Utils.info "Created table `#{table_name}`."
        _ ->
          Utils.warn "Table `#{table_name}` already exists."
      end
    end)
  end

  defp get_table_list() do
    dest_path = Path.join ~w(priv repo rethinkdb)
    dest_file_path = Path.join dest_path, @filename
    {:ok, tables} = File.read(dest_file_path)
    String.split(tables, "\n")
  end

  @doc """
  Ensures the given repository is started and running.
  """
  @spec ensure_started(Ecto.Repo.t) :: Ecto.Repo.t | no_return
  def ensure_started(repo) do
    {:ok, _} = Application.ensure_all_started(:ecto)

    case repo.start_link do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, _}} -> {:ok, nil}
      {:error, error} ->
        Mix.raise "could not start repo #{inspect repo}, error: #{inspect error}"
    end
  end
end
