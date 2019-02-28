# IIP

Intermediate Inspection of Pipelines.

## Include

The nature of this dependency lies in the simplicity of it, I therefore
recommend retrieving `iip.ex` as plaintext and use it whenever and wherever
necassary.

You can use various tools for this, such as `cURL` or by navigating to the
url in the browser.

## Usage

You can use IIP in various ways, the most common one might be to `use` it in a
module and to replace `|>` (Pipe) calls with `~>` (IIP) calls. This does
however require that either:

* IIP is a dependency
  ```elixir
  defp deps, do: [{:iip, git: "https://github.com/muse/iip"]
  ```

* `iip.ex` is loaded in (somewhere).

## Require

We're able to quickly load in IIP for debugging due to the small size of the
executable.

* Required by `elixir` through `-r`.
  ```bash
  $ elixir -r iip.ex
  ```

* Required by `iex` through `-r`.
  ```bash
  $ iex -r iip.ex
  ```

* When developing *in* `IIP`.
  ```bash
  $ iex -S mix
  ```

* As a dependency, shown above.

## Example(s)

```elixir
defmodule A do
  @moduledoc false

  # Inclusion of IIP with an optional option list.
  use IIP, []

  # This is the standard `inspector` function.
  def inspector(value) do
    value
  end

  # Using the `~>` operator rather than the `|>` operator.
  def act do
    1
    ~> Kernel.+(5)
    ~> Kernel.-(10)
  end
end

A.act
```

-----

```elixir
defmodule B do
  @moduledoc """
  Inspecting a `Stream.element`.
  """

  # We can "cheat" by limiting the output of `IO.inspect`, this way we're able
  # to observe our `Logger.log` call better.
  use IIP, limit: 0

  require Logger

  @spec inspector(%Stream{} | function) :: %Stream{} | function
  defp inspector(value) do
    Logger.log :debug, "[Logger] `Stream.element`: #{inspect(Enum.to_list value)}"

    value
  end

  @spec act :: :ok
  def act do
    [{1, <<0>>}, {2, <<0>>}, {3, <<0>>},
     {1, <<0>>}, {2, <<0>>}, {3, <<0>>}]
    ~> Stream.uniq
    ~> Stream.map(& {elem(&1, 0) + 1, <<1>>})
    ~> Stream.run
  end
end

B.act
```
