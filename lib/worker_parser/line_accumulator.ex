defmodule DocsetGenerator.WorkerParser.LineAccumulator do
  alias DocsetGenerator.WorkerParser.RegexMatcher

  def start_link() do
    Agent.start_link(fn -> %{:acc => "", :lines_read => 0} end)
  end

  @doc """
  Accumulates the received line into a single string for regex matching.
  """
  def add_line(line_acc, line, caller) do
    case line do
      line when is_binary(line) ->
        Agent.update(line_acc, fn %{:lines_read => lr, :acc => acc} ->
          accumulated_string = acc <> line

          case attempt_match_entry(accumulated_string) do
            [] ->
              %{:lines_read => lr + 1, :acc => accumulated_string}

            [entry] ->
              send(caller, entry)
              %{:lines_read => lr + 1, :acc => ""}

          end
        end)

      _ ->
        send(caller, :eol)
    end
  end

  @doc """
  Tests against all regex functions and gets the first one that matches.
  """
  def attempt_match_entry(accumulated_string) do
    RegexMatcher.matcher_functions()
    |> Stream.transform(nil, fn match_fn, _ ->
      entry = match_fn.(accumulated_string)
      if is_nil(entry), do: {[nil], nil}, else: {:halt, entry}
    end)
    |> Stream.filter(&not is_nil(&1))
    |> Enum.take(1)
  end
end
