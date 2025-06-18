defmodule AshPyro.MixProject do
  @moduledoc false
  use Mix.Project

  @source_url "https://github.com/frankdugan3/ash_pyro"
  @version "0.2.1"
  @description """
  Declarative UI for Ash Framework.
  """
  def project do
    [
      app: :ash_pyro,
      version: @version,
      description: @description,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      test_paths: ["test"],
      name: "AshPyro",
      source_url: @source_url,
      elixirc_paths: elixirc_paths(Mix.env()),
      consolidate_protocols: Mix.env() != :test,
      aliases: aliases(),
      compilers: [:yecc] ++ Mix.compilers(),
      dialyzer: [plt_add_apps: [:ash, :spark, :ecto, :mix]]
    ]
  end

  def cli do
    [
      preferred_envs: [
        "test.watch": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  defp extras do
    "documentation/**/*.md"
    |> Path.wildcard()
    |> Enum.map(fn path ->
      title =
        path
        |> Path.basename(".md")
        |> String.split(~r/[-_]/)
        |> Enum.map_join(" ", &String.capitalize/1)

      {String.to_atom(path),
       [
         title: title,
         default: title == "Get Started"
       ]}
    end)
  end

  defp groups_for_extras do
    [
      Tutorials: [
        "documentation/tutorials/get-started.md",
        ~r'documentation/tutorials'
      ]
    ]
  end

  defp docs do
    [
      main: "about",
      source_ref: "v#{@version}",
      output: "doc",
      source_url: @source_url,
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules(),
      groups_for_docs: [
        Macros: &(&1[:type] == :macro)
      ],
      nest_modules_by_prefix: [
        AshPyro.Extensions.Resource
      ]
    ]
  end

  defp package do
    [
      name: :ash_pyro,
      maintainers: ["Frank Dugan III"],
      licenses: ["MIT"],
      links: %{GitHub: @source_url},
      files:
        ~w(lib documentation) ++
          ~w(README* CHANGELOG* LICENSE* mix.exs .formatter.exs)
    ]
  end

  defp groups_for_modules do
    [
      Core: [
        AshPyro,
        AshPyro.Helpers
      ],
      "Ash Resource Extension": [
        ~r/AshPyro.Extensions.Resource/
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Dev tooling
      {:credo, ">= 0.0.0", only: [:test, :dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:doctor, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_check, "~> 0.15",
       [env: :prod, hex: "ex_check", only: :dev, runtime: false, repo: "hexpm"]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:git_ops, "~> 2.6", only: :dev},
      {:mix_audit, ">= 0.0.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:usage_rules, "~> 0.1", only: [:dev]},
      # Core dependencies
      {:ash, "~> 3.0"},
      {:igniter, "~> 0.6", optional: true},
      {:spark, "~> 2.2.63"}
    ]
  end

  defp aliases do
    [
      rules: "usage_rules.sync CLAUDE.md --all --link-to-folder deps --link-style at --yes",
      update: ["deps.update --all", "rules"],
      format: ["format --migrate"],
      build: [
        "spark.formatter --extensions AshPyro.Extensions.Resource",
        "format"
      ],
      # until we hit 1.0, we will ensure no major release!
      release: [
        "build",
        "git_ops.release --no-major"
      ],
      publish: [
        "hex.publish"
      ],
      setup: [
        "deps.get",
        "compile",
        "docs"
      ]
    ]
  end
end
