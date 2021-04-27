# https://shyr.io/blog/iex-copy-to-clipboard
# https://hexdocs.pm/iex/IEx.html#module-the-iex-exs-file
#
# Usage:
#
# iex(1)> User |> Repo.get!(user_id) |> Helpers.copy
# :ok
#
# iex(1)> User |> Repo.get!(user_id)
# iex(2)> Helpers.copy(v) # v returns the last output
# :ok
#
defmodule Helpers do
  def copy(term) do
    text =
      if is_binary(term) do
        term
      else
        inspect(term, limit: :infinity, pretty: true)
      end

    port = Port.open({:spawn, "pbcopy"}, [])
    true = Port.command(port, text)
    true = Port.close(port)

    :ok
  end
end
