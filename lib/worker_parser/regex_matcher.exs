defmodule DocsetGenerator.WorkerParser.RegexMatcher do
  alias DocsetGenerator.WorkerParser.RegexMatcher

  def matcher_functions() do
    """
    More specific matchers take precedence over generic matchers.
    Example: match_type, match_callback and match_function all refer to function types, but match_function matches generic functions with no qualifier, thus it comes last.
    """

    [
      # type - topics, small docs, guides
      RegexMatcher.match_guide(),
      # type - module
      RegexMatcher.match_module_behaviour(),
      RegexMatcher.match_module_exception(),
      RegexMatcher.match_module(),
      # type - functions
      RegexMatcher.match_type(),
      RegexMatcher.match_callback(),
      RegexMatcher.match_function()
    ]
  end

  def match_function(str) do
    case Regex.run(~r/id="(.+\/[0-9]+)"/, str) do
      nil ->
        nil

      entry ->
        %{:title => entry[1], :anchor => entry[0], :type => :function}
    end
  end

  def match_type(str) do
    case Regex.run(~r/id="t:(.+\/[0-9]+)"/, str) do
      nil ->
        nil

      entry ->
        %{:title => entry[1], :anchor => entry[0], :type => :type}
    end
  end

  def match_callback(str) do
    case Regex.run(~r/id="c:(.+\/[0-9]+)"/, str) do
      nil ->
        nil

      entry ->
        %{:title => entry[1], :anchor => entry[0], :type => :callback}
    end
  end

  def match_guide(str) do
    """
    <h2 id="module-custom-channels" class="section-heading">
      <a href="#module-custom-channels" class="hover-link">
        <span class="icon-link" aria-hidden="true"></span>
      </a>
      Custom channels <-- guide name
    </h2>
    """

    case Regex.run(
           ~r/<h2 id="(module-.+)" class="section-heading".+>(.*)<\/h2>/,
           str
         ) do
      nil ->
        nil

      entry ->
        %{:title => entry[0], :anchor => entry[1], :type => :guide}
    end
  end

  def match_module(str) do
    """
    <div id="content" class="content-inner">
    <h1>
      <small class="visible-xs">Phoenix v1.4.2</small>
      Phoenix.Socket <-- module name
      <small>behaviour</small> <-- qualifier
      <a href="https://github.com/phoenixframework/phoenix/blob/v1.4.2/lib/phoenix/socket.ex#L1" title="View Source" class="view-source" rel="help">
        <span class="icon-code" aria-hidden="true"></span>
        <span class="sr-only">View Source</span>
      </a>
    </h1>
    <section id="moduledoc">
    """

    case Regex.run(
           ~r/<h1><small class="visible-xs">Phoenix.+<\/small>(.*)<a h/,
           str
         ) do
      nil ->
        nil

      entry ->
        %{:title => entry[1], :anchor => "moduledoc", :type => :module}
    end
  end

  def match_module_behaviour(str) do
    case Regex.run(
           ~r/<h1><small class="visible-xs">Phoenix.+<\/small>(.*)<small>behaviour<\/small>/,
           str
         ) do
      nil ->
        nil

      entry ->
        %{:title => entry[1], :anchor => "moduledoc", :type => :module}
    end
  end

  def match_module_exception(str) do
    case Regex.run(
           ~r/<h1><small class="visible-xs">Phoenix.+<\/small>(.*)<small>exception<\/small>/,
           str
         ) do
      nil ->
        nil

      entry ->
        %{:title => entry[1], :anchor => "moduledoc", :type => :module}
    end
  end
end
