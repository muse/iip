defmodule IIPTest do
  @moduledoc false
  @module IIP

  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  doctest @module

  @spec cleanse(module) :: boolean
  defp cleanse(module) do
    :code.purge(module)
    :code.delete(module)
  end

  describe "use IIP" do
    test "Will use the standard &inspector/1" do
      defmodule Test do
        @moduledoc false
        use IIP

        @doc false
        @spec run :: :ok
        def run do
          assert <<"1", "\n", "2", "\n">>
             === capture_io(fn ->
                   1 ~> Kernel.+(1)
                 end)

          assert <<"[1, 2, 3]", "\n", "[2, 3, 4]", "\n">>
             === capture_io(fn ->
                   [1, 2, 3] ~> Enum.map(&(&1 + 1))
                 end)

          :ok
        end
      end

      assert :ok
         === Test.run()
      assert cleanse(Test)
    end

    test "Will overwrite &inspector/1" do
      defmodule Test do
        @moduledoc false
        use IIP

        def inspector(value) when is_list(value) do
          value
          |> Enum.map(&(&1 - 1))
          |> IO.inspect()

          value
        end

        def inspector(value) do
          IO.inspect(value - 1)

          value
        end

        @doc false
        @spec run :: any
        def run do
          assert <<"0", "\n", "1", "\n", "2", "\n">>
             === capture_io(fn ->
                   1 ~> Kernel.+(1)
                 end)

          assert <<"[0, 1, 2]", "\n", "[1, 2, 3]", "\n", "[2, 3, 4]", "\n">>
             === capture_io(fn ->
                   [1, 2, 3] ~> Enum.map(&(&1 + 1))
                 end)

          :ok
        end
      end

      assert :ok
         === Test.run()
      assert cleanse(Test)
    end

    test "Will accept Inspect.Opts options as `use` argument" do
    end
  end

  describe "left ~> right" do
    test "Will accept various left hand side values" do
      defmodule Test do
        @moduledoc false
        use IIP

        @spec incrementer({number, number} | number) :: number
        defp incrementer({k, v}) do
          {k + 1, v + 1}
        end

        defp incrementer(v) do
          v + 1
        end

        @doc false
        @spec run :: :ok
        def run do
          assert 2
             === 1 ~> Kernel.+(1)

          assert 2.0
             === 1.0 ~> Kernel.+(1.0)

          assert [2, 2, 2]
             === [1, 1, 1] ~> Enum.map(&incrementer/1)

          assert %{2 => 2}
             === %{1 => 1} ~> Enum.into(%{}, &incrementer/1)

          assert [{2, 2}]
             === [{1, 1}] ~> Enum.into([], &incrementer/1)

          assert {2, 2}
             === {1, 1} ~> incrementer()

          :ok
        end
      end

      assert :ok
         === Test.run()
      assert cleanse(Test)
    end
  end
end
