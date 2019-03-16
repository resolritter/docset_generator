defmodule DocsetGenerator.WorkerParser.RegexMatcher do
  alias DocsetGenerator.WorkerParser.RegexMatcher
  def matcher_functions() do
    [
      RegexMatcher.match_module_function
    ]
  end

  def match_module_function() do
    # TODO
  end
end
