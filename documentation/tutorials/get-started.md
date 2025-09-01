# Get Started

This guide steps through the installation process for PyroManiac.

## Installation

The installation process is pretty straightforward.

### Steps

These steps assume you understand how to install and use Ash, and does not cover its installation or configuration.

1. Add the appropriate dependencies:

   ```elixir
   def deps do
     [
    {:pyro_maniac, "~> 0.2.1"},
    {:ash, "~> 2.4"},
     ]
   end
   ```

2. Compare your `.formatter.exs` to this example and add anything you are missing:

   ```elixir
   [
     import_deps: [:pyro_maniac, :ash],
     plugins: [Spark.Formatter]
   ]
   ```
