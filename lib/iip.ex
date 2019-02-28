defmodule IIP do
  @moduledoc """
  IIP is an extension on top of the pipe operator. It will show the value
  that's being passed through and continue like the normal pipe operator
  afterwards. IIP can can be `used` with an additional option set, this option
  set coincides with the standard `Inspect.Opts` options.

  ## Examples

     1 defmodule Addition do
     2   @moduledoc false
     3   use IIP, []
     4
     5   @spec add(number, number) :: number
     6   def add(a, b) do
     7     a
     8     ~> Kernel.+(b)
     9     ~> Kernel.-(a)
    10   end
    11 end

  $ Addition.add(1, 5)

    L &Addition.add/2 on L8: 1
    R &Addition.add/2 on L8: 6
    L &Addition.add/2 on L9: 6
    R &Addition.add/2 on L9: 5

  """

  defmacro __using__(options) do
    quote do
      import IIP

      @options unquote(options)

      @doc """
      The `inspector` function can be used to mutate and view data in-between
      pipe calls, this function standardizes the return value as the literal
      supplied value, this means the function can be not-implemented to receive
      the standard behavior.
      """
      @spec inspector(any) :: any
      def inspector(value) do
        value
      end

      defoverridable inspector: 1
    end
  end

  defmacro left ~> right do
    quote do
      unquote(left)
      |> inspector
      |> IO.inspect(@options)
      |> unquote(right)
      |> IO.inspect(@options)
    end
  end
end
