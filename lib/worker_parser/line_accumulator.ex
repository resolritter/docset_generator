defmodule DocsetGenerator.WorkerParser.LineAccumulator do
  alias DocsetGenerator.WorkerParser.EntryCollector

  def start_link(filepath, parser_functions) do
    Agent.start_link(
      fn ->
        %{
          :parser_functions => parser_functions,
          :acc => ""
        }
      end,
      name: agent_name(filepath)
    )
  end

  def agent_name(filepath), do: {:global, filepath <> "--accumulator"}

  @doc """
  Accumulates the received line into a single string for regex matching.
  """
  def add_line(filepath, line) do
    case line do
      :ok ->
        EntryCollector.stop_collecting(filepath)

      line ->
        Agent.update(agent_name(filepath), fn %{
                                                :parser_functions =>
                                                  parser_functions,
                                                :acc => acc
                                              } ->
          accumulated_string = acc <> line

          case attempt_match_entry(parser_functions, accumulated_string) do
            [] ->
              acc

            [entry] ->
              EntryCollector.collect_new_entry(filepath, entry)
              %{:parser_functions => parser_functions, :acc => acc}
          end
        end)
    end
  end

  @doc """
  Tests against all regex functions and gets the first one that matches.
  """
  def attempt_match_entry(parser_functions, accumulated_string) do
    parser_functions
    |> Stream.transform(nil, fn parser_function, _ ->
      entry = parser_function.(accumulated_string)
      if is_nil(entry), do: {[nil], nil}, else: {:halt, entry}
    end)
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.take(1)
  end
end
