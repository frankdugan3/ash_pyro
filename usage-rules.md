# Rules for working with PyroManiac

## Understanding PyroManiac

PyroManiac is an opinionated, composable framework for building user interfaces in Elixir. It provides a declarative approach to modeling user interfaces with Ash resources at the center. Read documentation _before_ attempting to use its features. Do not assume that you have prior knowledge of the framework or its conventions.

## Generating Code

MANDATORY - NO EXCEPTIONS:

Always prefer to use generators as a basis for code generation, and then modify afterwards.

1. First, use `list_generators` to list available generators when available, otherwise `mix help`.
2. If you have to run generator tasks, pass `--yes`.
3. Use available generators to scaffold code
4. Modify code to meet requirements
