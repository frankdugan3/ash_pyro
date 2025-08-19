defmodule AshPyro.Extensions.Dsl.Form.Field do
  @moduledoc """
  The configuration of a form field in the `AshPyro.Extensions.Resource` extension.
  """

  use AshPyro.Extensions.Dsl.Schema

  alias Spark.Dsl.Entity

  defstruct [
    :autocomplete_option_label_key,
    :autocomplete_option_value_key,
    :autocomplete_search_action,
    :autocomplete_search_arg,
    :autofocus,
    :class,
    :description,
    :input_class,
    :label,
    :name,
    :options,
    :path,
    :prompt,
    :type
  ]

  @type field_type ::
          :default | :long_text | :short_text | :autocomplete | :select | :nested_form

  @type t :: %__MODULE__{
          autocomplete_option_label_key: atom(),
          autocomplete_option_value_key: atom(),
          autocomplete_search_action: atom(),
          autocomplete_search_arg: atom(),
          autofocus: boolean(),
          class: String.t(),
          description: String.t(),
          input_class: String.t(),
          label: String.t(),
          name: atom(),
          options: list(),
          path: [atom()],
          prompt: String.t(),
          type: field_type()
        }

  @schema [
    name: [
      type: :atom,
      required: true,
      doc: "The name of the field to be modified"
    ],
    type: [
      type: {:in, [:default, :long_text, :short_text, :autocomplete, :select, :nested_form]},
      required: false,
      doc: "The type of the value in the form.",
      default: :default
    ],
    options: [
      type: {:list, :any},
      required: false,
      doc: "The options for a select type input.",
      default: []
    ],
    label: [
      type: :string,
      required: false,
      doc: "The label of the field (defaults to capitalized name)."
    ],
    description: [
      type: :string,
      required: false,
      doc: "Override the default extracted description."
    ],
    class: [
      type: css_class_schema_type(),
      required: false,
      doc: "Customize class."
    ],
    input_class: [
      type: css_class_schema_type(),
      required: false,
      doc: "Customize input class."
    ],
    autofocus: [
      type: :boolean,
      required: false,
      default: false,
      doc: "Autofocus the field."
    ],
    prompt: [
      type: :string,
      required: false,
      doc: "Override the default prompt."
    ],
    path: [
      type: {:list, :atom},
      required: false,
      doc: "Append to the root path (nested paths are appended)."
    ],
    autocomplete_search_action: [
      type: :atom,
      default: :read,
      doc: "Set the autocomplete search action name."
    ],
    autocomplete_search_arg: [
      type: :atom,
      default: nil,
      doc: "Set the autocomplete search argument key."
    ],
    autocomplete_option_label_key: [
      type: :atom,
      required: false,
      default: :label,
      doc: "Override the default autocomplete key used as a label."
    ],
    autocomplete_option_value_key: [
      type: :atom,
      required: false,
      default: :id,
      doc: "Override the default autocomplete key used as a value."
    ]
  ]

  @entity %Entity{
    args: [:name],
    describe:
      "Declare non-default behavior for a specific form field in the `AshPyro.Extensions.Dsl` extension.",
    name: :field,
    schema: @schema,
    target: __MODULE__
  }

  @doc false
  def entity, do: @entity
end
