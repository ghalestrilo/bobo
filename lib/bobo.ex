defmodule Bobo do
  @moduledoc """
  Bobo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def say(args) do
    IO.puts("Hello, #{args}")
  end
end
