[![hex.pm](https://img.shields.io/hexpm/l/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![hex.pm](https://img.shields.io/hexpm/v/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/ash_pyro)
[![hex.pm](https://img.shields.io/hexpm/dt/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![github.com](https://img.shields.io/github/last-commit/frankdugan3/ash_pyro.svg)](https://github.com/frankdugan3/ash_pyro)

# AshPyro

Pyro is a suite of libraries for building UI in Phoenix.

[Pyro](https://hexdocs.pm/pyro)

- [Component tooling](https://hexdocs.pm/pyro/Pyro.Component.html) for Phoenix LiveView
- [Customizable](https://hexdocs.pm/pyro/Pyro.Overrides.html) override system (skins/themes)

[PyroComponents](https://hexdocs.pm/pyro_components)

- A library of [pre-built components](https://hexdocs.pm/pyro_components)
- A set of [preset overrides](https://hexdocs.pm/pyro_components/PyroComponents.Overrides.BEM) to get started quickly while allowing deep customization

[AshPyro](https://hexdocs.pm/ash_pyro)

- [Ash extensions](https://hexdocs.pm/ash_pyro/AshPyro.Extensions.Resource.html) providing a declarative UI DSL

[AshPyroComponents](https://hexdocs.pm/ash_pyro_components)

- A [library of components](https://hexdocs.pm/ash_pyro_components/AshPyroComponents.html) that automatically render AshPyro DSL with PyroComponents

For more details, check out the [About](https://hexdocs.pm/pyro/about.html) page

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
