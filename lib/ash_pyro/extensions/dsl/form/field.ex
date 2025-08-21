defmodule AshPyro.Extensions.Dsl.Form.Field do
  @moduledoc """
  The configuration of a form field in the `AshPyro.Extensions.Resource` extension.
  """

  use AshPyro.Extensions.Dsl.Entity,
    args: [:name],
    describe:
      "Declare non-default behavior for a specific form field in the `AshPyro.Extensions.Dsl` extension.",
    name: :field,
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "The name of the field to be modified"
      ],
      type: [
        type:
          {:one_of, [:default, :long_text, :short_text, :autocomplete, :select, :nested_form]},
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
        type: :css_class,
        required: false,
        doc: "Customize class."
      ],
      input_class: [
        type: :css_class,
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
end
