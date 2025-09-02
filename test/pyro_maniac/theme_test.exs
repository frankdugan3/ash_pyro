defmodule PyroManiac.ThemeTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias PyroManiac.Theme.BaseClass
  alias PyroManiac.Theme.BEM
  alias Spark.Dsl.Extension
  alias Spark.Error.DslError

  doctest PyroManiac.Theme, import: true

  describe "theme" do
    test "prepends prefix" do
      prefix = Extension.get_opt(BEM, [:theme], :prefix)

      BEM
      |> Extension.get_entities([:theme])
      |> Enum.each(fn
        %BaseClass{} = base_class ->
          assert prefix <> base_class.value == base_class.prefixed

        _ ->
          :ok
      end)
    end

    test "validates base class implementation" do
      [missing | implemented] = PyroManiac.Theme.base_class_names()

      assert_raise DslError,
                   """
                   [PyroManiac.ThemeTest.CustomTheme.MissingBaseClass]
                   theme -> base_class:
                     The following base classes are not defined:

                     #{inspect(missing)}
                   """,
                   fn ->
                     defmodule CustomTheme.MissingBaseClass do
                       use PyroManiac.Theme

                       theme do
                         for name <- implemented do
                           base_class name, "#{name}"
                         end
                       end
                     end
                   end
    end
  end
end
