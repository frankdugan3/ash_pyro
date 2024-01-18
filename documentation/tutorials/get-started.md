# Get Started

This guide steps through the installation process for AshPyro.

## Installation

The installation process is pretty straightforward.

### Steps

These steps assume you understand how to install and use Ash, and does not cover its installation or configuration.

1. Add the appropriate dependencies:

   ```elixir
   def deps do
     [
    {:ash_pyro, "~> 0.0.1"},
    {:ash, "~> 2.4"},
     ]
   end
   ```

2. Compare your `.formatter.exs` to this example and add anything you are missing:

   ```elixir
   [
     import_deps: [:ash_pyro, :ash],
     plugins: [Spark.Formatter]
   ]
   ```
