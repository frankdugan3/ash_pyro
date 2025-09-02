defmodule PyroManiac.Theme.BaseClass do
  @moduledoc """
  Base class for a component block.
  """
  use PyroManiac.Dsl.Entity,
    args: [:name, :value],
    name: :base_class,
    identifier: :name,
    # quokka:sort
    schema: [
      __identifier__: [private?: true],
      name: [
        doc: "UI component for class",
        required: true,
        type: {
          :one_of,
          # quokka:sort
          [
            :data_table,
            :form
          ]
        }
      ],
      prefixed: [type: :string, private?: true],
      value: [
        doc: "Class value",
        required: true,
        type: :string
      ]
    ]
end
