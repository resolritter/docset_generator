defmodule DocsetGenerator.WorkerParser.RegexMatcher.Elixir do
  alias DocsetGenerator.WorkerParser.RegexMatcher.Entry
  @behaviour DocsetGenerator.WorkerParser.RegexMatcher
  @self __MODULE__

  def matcher_functions() do
    [
      # type - topics, small docs, guides
      &@self.match_guide(&1),
      # type - module
      &@self.match_module_behaviour(&1),
      &@self.match_module_exception(&1),
      &@self.match_module(&1),
      # type - functions
      &@self.match_type(&1),
      &@self.match_callback(&1),
      &@self.match_function(&1)
    ]
  end

  def match_function(str) do
    case Regex.run(~r/id="(.+\/[0-9]+)"/, str) do
      nil ->
        nil

      entry ->
        %Entry{:title => entry[1], :anchor => entry[0], :type => :function}
    end
  end

  def match_type(str) do
    case Regex.run(~r/id="t:(.+\/[0-9]+)"/, str) do
      nil ->
        nil

      entry ->
        %Entry{:title => entry[1], :anchor => entry[0], :type => :type}
    end
  end

  def match_callback(str) do
    case Regex.run(~r/id="c:(.+\/[0-9]+)"/, str) do
      nil ->
        nil

      entry ->
        %Entry{:title => entry[1], :anchor => entry[0], :type => :callback}
    end
  end

  @doc """
  Matches the pattern

  ```
  <h2 id="module-custom-channels" class="section-heading">
    <a href="#module-custom-channels" class="hover-link">
      <span class="icon-link" aria-hidden="true"></span>
    </a>
    Custom channels <-- guide name
  </h2>
  ```
  """
  def match_guide(str) do
    case Regex.run(
           ~r/<h2 id="(module-.+)" class="section-heading".+>(.*)<\/h2>/,
           str
         ) do
      nil ->
        nil

      entry ->
        %Entry{:title => entry[0], :anchor => entry[1], :type => :guide}
    end
  end

  @doc """
  Matches the pattern

  ```
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
  ```
  """
  def match_module(str) do
    case Regex.run(
           ~r/<h1><small class="visible-xs">Phoenix.+<\/small>(.*)<a h/,
           str
         ) do
      nil ->
        nil

      entry ->
        %Entry{:title => entry[1], :anchor => "moduledoc", :type => :module}
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
        %Entry{:title => entry[1], :anchor => "moduledoc", :type => :module}
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
        %Entry{:title => entry[1], :anchor => "moduledoc", :type => :module}
    end
  end
end
