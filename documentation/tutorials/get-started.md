# Get Started

This guide steps through the installation process for AshPyro.

## Installation

The installation process is pretty straightforward.

### Steps

These steps assume you are adding AshPyro to an existing Phoenix LiveView app, as generated from the most recent version of `phx.new`. It also assumes you understand how to install and use Ash, and does not cover its installation or configuration.

#### Option A: Just the DSL

1. Add the appropriate dependencies:

   ```elixir
   def deps do
     [
    {:ash_pyro, "~> 0.0.0"},
    {:ash, "~> 2.4"},
     ]
   end
   ```

2. Compare your `.formatter.exs` to this example and add anything you are missing:

   ```elixir
   [
     import_deps: [:ash_pyro, :ash],
     plugins: [Spark.Formatter, Phoenix.LiveView.HTMLFormatter],
     inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}"]
   ]
   ```

#### Option B: DSL and Pyro Component Tooling

1. Add the appropriate dependencies:

   ```elixir
   def deps do
     [
      {:pyro, "~> 0.3"},
      {:ash_pyro, "~> 0.0.0"},
      {:ash, "~> 2.4"},

      ### OPTIONAL DEPS BELOW ###

      # Date/Time/Zone components & tooling
      {:tz, "~> 0.26"},
      {:tz_extra, "~> 0.26"},
      #   or
      {:tzdata, "~> 1.1"},
     ]
   end
   ```

2. Compare your `.formatter.exs` to this example and add anything you are missing:

   ```elixir
   [
     import_deps: [:phoenix, :pyro, :ash_pyro, :ash],
     plugins: [Phoenix.LiveView.HTMLFormatter],
     inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}"]
   ]
   ```

3. Add the following to your `config.exs`:

   ```elixir
   config :pyro, :overrides, [MyApp.Overrides]
   config :pyro, gettext: MyApp.Gettext # optional
   ```

   See `Pyro.Overrides` to learn how to create your own overrides file.

4. Edit your `my_app_web.ex` file, replacing:

   - `Phoenix.Component` with `AshPyro.Component`
   - `Phoenix.LiveComponent` with `AshPyro.LiveComponent`
   - `Phoenix.LiveView` with `AshPyro.LiveView`

   **Note:** _Only_ replace those top-level modules, _do not_ replace submodules, e.g. `Phoenix.LiveView.Router`.

5. (Optional) configure some runtime options in `runtime.exs`:

   ```elixir
   config :pyro, default_timezone: "America/Chicago"
   ```
