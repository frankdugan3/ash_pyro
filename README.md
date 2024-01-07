[![hex.pm](https://img.shields.io/hexpm/l/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![hex.pm](https://img.shields.io/hexpm/v/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/ash_pyro)
[![hex.pm](https://img.shields.io/hexpm/dt/ash_pyro.svg)](https://hex.pm/packages/ash_pyro)
[![github.com](https://img.shields.io/github/last-commit/frankdugan3/ash_pyro.svg)](https://github.com/frankdugan3/ash_pyro)

# AshPyro

Declarative UI for Ash Framework.

**NOTICE:** This library is under heavy development. Expect frequent breaking
changes until the first stable v1.0 release is out.

AshPyro's documentation is housed on [hexdocs](https://hexdocs.pm/ash_pyro), which includes detailed [installation instructions](https://hexdocs.pm/ash_pyro/get-started.html) and other guides.

## Installation

Installation is covered in the [Get Started](https://hexdocs.pm/ash_pyro/get-started.html) guide.

## What is AshPyro?

AshPyro provides:

1. An [Ash extension](https://hexdocs.pm/ash_pyro/AshPyro.Extensions.Resource.html) providing a declarative UI DSL
2. A [library of components](https://hexdocs.pm/ash_pyro/AshPyro.Components.html) that automatically render the UI DSL

For more details, check out the [About](https://hexdocs.pm/ash_pyro/about.html) page.

It leverages the related package [Pyro](https://hexdocs.pm/pyro), which provides:

1. [Component tooling](https://hexdocs.pm/pyro/Pyro.Component.html) for Phoenix LiveView
2. A library of [pre-built components](https://hexdocs.pm/pyro/Pyro.Components.Core.html)
3. A set of [default](https://hexdocs.pm/pyro/Pyro.Overrides.Default.html), [customizable](https://hexdocs.pm/pyro/Pyro.Overrides.html) skins

## Development

As long as Elixir is already installed:

```sh
git clone git@github.com:frankdugan3/ash_pyro.git
cd ash_pyro
mix setup
```

For writing docs, there is a handy watcher script that automatically rebuilds/reloads the docs locally: `./watch_docs.sh`
