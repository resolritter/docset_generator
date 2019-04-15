defmodule DocsetGenerator.WorkerParser.RegexMatcher do
  alias DocsetGenerator.WorkerParser.RegexMatcher.Entry

  @doc """
  More specific matchers take precedence over generic matchers.
  Example: match_type, match_callback and match_function all refer to function types, but match_function matches generic functions with no qualifier, thus it comes last.

  The list of callbacks returned should always take a string and attempt to return an entry from it.
  """
  @callback matcher_functions() :: list(fun(((String) -> nil | Entry)))
end

defmodule DocsetGenerator.WorkerParser.RegexMatcher.Entry do
  defstruct [:title, :anchor, :type]
end
