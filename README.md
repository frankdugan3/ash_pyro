[![hex.pm](https://img.shields.io/hexpm/l/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![hex.pm](https://img.shields.io/hexpm/v/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/ash_pyro)
[![hex.pm](https://img.shields.io/hexpm/dt/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![github.com](https://img.shields.io/github/last-commit/frankdugan3/ash_pyro.svg)](https://github.com/frankdugan3/ash_pyro)

# AshPyro

Pyro is a suite of libraries for building UI in Phoenix.

- [Pyro](https://hexdocs.pm/pyro)

  Component tooling for Phoenix.

  - Customizable "overrides" system for granularly customizable themes
  - Extended component attributes, e.g. CSS merging

- [PyroComponents](https://hexdocs.pm/pyro_components)

  Ready-made Phoenix components, built with pyro.

  - Heex component library
  - Overrides presets to get started quickly while allowing deep customization

- [AshPyro](https://hexdocs.pm/ash_pyro)

  Declarative UI for Ash Framework.

  - Ash extensions providing a declarative UI DSL

- [AshPyroComponents](https://hexdocs.pm/ash_pyro_components)

  Components that automatically render PyroComponents declaratively via AshPyro.

## About

For more details on AshPyro, check out the [About](https://hexdocs.pm/ash_pyro/about.html) page.

## Installation

To install `AshPyro` and add declarative UI DSL to your Ash project, follow the [Get Started](https://hexdocs.pm/ash_pyro/get-started.html) guide. For the other features, please see the "Get Started" guide for the appropriate library instead.

## Development

As long as Elixir is already installed:

```sh
git clone git@github.com:frankdugan3/ash_pyro.git
cd ash_pyro
mix setup
```

For writing docs, there is a handy watcher script that automatically rebuilds/reloads the docs locally: `./watch_docs.sh`

## Prior Art

- [AshAdmin](https://github.com/ash-project/ash_admin): An admin ui for Ash Resources.
