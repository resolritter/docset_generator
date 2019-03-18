defmodule DocsetGenerator.WorkerParser.LineAccumulator do
  alias DocsetGenerator.WorkerParser.RegexMatcher

  def start_link() do
    Agent.start_link(%{:lines_read => 0, :acc => ""})
  end

  def add_line(line_acc, line, caller) do
    case line do
      line when is_binary(line) ->
        Agent.update(line_acc, fn %{:lines_read => lr, :acc => acc} ->
          accumulated_string = acc <> line

          case attempt_match_entry(accumulated_string) do
            entry ->
              send(caller, entry)
              %{:lines_read => lr + 1, :acc => ""}

            nil ->
              %{:lines_read => lr + 1, :acc => accumulated_string}
          end
        end)

      _ ->
        send(caller, :eol)
    end
  end

  def attempt_match_entry(accumulated_string) do
    RegexMatcher.matcher_functions()
    |> Stream.transform(_, fn match_fn, _ ->
      entry = match_fn.(accumulated_string)
      if is_nil(entry), do: {[nil], nil}, else: {:halt, entry}
    end)
    |> Stream.filter(&(&1 |> is_nil |> not))
    |> Enum.take(1)
    |> List.first
  end
end
