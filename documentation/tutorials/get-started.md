# Get Started

This guide steps through the installation process for AshPyro.

## Installation

The installation process is pretty straightforward.

### Steps

These steps assume you are adding AshPyro to an existing Phoenix LiveView app, as generated from the most recent version of `phx.new`. It also assumes you understand how to install and use Ash, and does not cover its installation or configuration.

1. Add the appropriate dependencies:

   ```elixir
   def deps do
     [
    {:ash_postgres, "~> 1.0"},
    {:ash_pyro, "~> 0.0.0"},
    {:ash, "~> 2.4"},
     ]
   end
   ```

2. Compare your `.formatter.exs` to this example and add anything you are missing:

   ```elixir
   [
     import_deps: [:phoenix, :ash_pyro, :ash, :ash_postgres],
     subdirectories: ["priv/*/migrations"],
     plugins: [Spark.Formatter, Phoenix.LiveView.HTMLFormatter],
     inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}"]
   ]
   ```
