[![hex.pm](https://img.shields.io/hexpm/l/pyro_maniac.svg)](https://hex.pm/packages/pyro_maniac)
[![hex.pm](https://img.shields.io/hexpm/v/pyro_maniac.svg)](https://hex.pm/packages/pyro_maniac)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/pyro_maniac)
[![hex.pm](https://img.shields.io/hexpm/dt/pyro_maniac.svg)](https://hex.pm/packages/pyro_maniac)
[![github.com](https://img.shields.io/github/last-commit/frankdugan3/pyro_maniac.svg)](https://github.com/frankdugan3/pyro_maniac)

# PyroManiac

Extensible, declarative UI for Ash Framework.

- Compile-time validation of UI correctness
- Data Tables
  - Sorting
  - Filtering
  - Pagination
- Forms
  - Manage Relationships
  - Field Groups
  - Wizards
- Built-in components for Phoenix LiveView
- Built-in components for Hologram
- Customizable themes
  - DaisyUI preset
  - BEM preset (bring your own CSS)

## About

For more details on PyroManiac, check out the [About](https://hexdocs.pm/pyro_maniac/about.html) page.

## Installation

To install PyroManiac and add declarative UI DSL to your Ash project, follow the [Get Started](https://hexdocs.pm/pyro_maniac/get-started.html) guide. For the other features, please see the "Get Started" guide for the appropriate library instead.

## Development

As long as Elixir is already installed:

```sh
git clone git@github.com:frankdugan3/pyro_maniac.git
cd pyro_maniac
mix setup
```

For writing docs, there is a handy watcher script that automatically rebuilds/reloads the docs locally: `./watch_docs.sh`

## Prior Art

- [AshAdmin](https://github.com/ash-project/ash_admin): An admin ui for Ash Resources.
