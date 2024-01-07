# About

AshPyro is a component library for Phoenix.

It provides:

1. An [Ash extension](AshPyro.Extensions.Resource) providing a declarative UI DSL
2. A [library of components](AshPyro.Components) that automatically render the UI DSL

It leverages the related package [Pyro](https://hexdocs.pm/pyro), which provides:

1. [Component tooling](https://hexdocs.pm/pyro/Pyro.Component.html) for Phoenix LiveView
2. A library of [pre-built components](https://hexdocs.pm/pyro/Pyro.Components.Core.html)
3. A set of [default](https://hexdocs.pm/pyro/Pyro.Overrides.Default.html), [customizable](https://hexdocs.pm/pyro/Pyro.Overrides.html) skins

To install, follow the [Get Started](get-started.html) guide.

## What "problem" is it solving?

The default model of Phoenix is to generate, then customize. While this does provide great isolation, I have found it pretty tedious to repeatedly make very similar copy & paste boilerplate changes to the generated code _every_ time I create a new Phoenix app. Additionally, some things (like timezone localization and extended Ecto types) are quite complicated and it would be nice for them to be handled by a library that is updated with future improvements. Copy & pasting boilerplate will lead to maintenance burdens down the road.

The tricky part is handling all the bespoke features in each app while sharing as much as possible. The goal is to provide a wide array of helpers and components with sane defaults, while allowing _very_ granular overrides.

[Ash Framework](https://hexdocs.pm/ash) provides an _excellent_ foundation for this on the backend. Its deep extensibility allows the DSL to be extended, and that's exactly where Pyro pours on the gas! By combining the flexible configuration of components with Ash's extensible DSL, Pyro & AshPyro can seamlessly add declarative UI config to Phoenix LiveView.

## General Principles

Pyro is under-developed. Not all components adhere to every principles, but eventually these principles should prevail.

- Maximal flexibility
  - Application defaults through presets & custom overrides
  - Bespoke configuration (via DSL in resources)
  - Components allow overriding defaults through props
- Clean, standards-compliant HTML markup
  - Favor semantic HTML elements
  - Avoid excessive `div` tags
  - Adhere to [accessibility guidelines](https://www.w3.org/WAI/ARIA/apg/)
- Progressive enhancement
  - No external JS dependencies
  - No needless JS
  - Sensibly enhance UX with JS
- Responsive
- Internationalization support via `gettext`