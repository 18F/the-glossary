# The Glossary

The glossary is a set of definitions for common abbreviations and jargon found at TTS.

**[Human-readable version](https://github.com/18F/the-glossary/blob/main/glossary.md)**

[Machine-readable version](https://github.com/18F/the-glossary/blob/main/glossary.yml)

This glossary is based on the archived [procurement glossary](https://github.com/18F/procurement-glossary), so as of early 2022 has mostly procurement-related terms.

Definitions may not be expansive but should give readers enough context to conduct further research and discovery.

## Contributing a definition

Open an issue to either add an acronym or add a term. (Templates pending.)

Or, add the acronym / term to the glossary.yml file directly and open a pull request.

## Contributing to the code

Contributions are welcome!

A few guidelines:

- Prefer functional programming methods (pure functions, immutability, etc.).
  - Use case statements as much as possible, making sure to cover all branches. Aggressively raise RuntimeErrors with clear messages if getting into impossible states.
- Try to maintain data integrity guarantees. For example, once our validations run, we can be sure of the format and structure of the data. Let's keep that guarantee and create others.
- Make very friendly error messages that lead those editing the glossary.yml to properly structure their data.

Run tests with `rake test`.

Run the glossary validation with `bin/validate`.

Run the Markdown builder with `bin/build`.

## Validations

The following data validation steps are run on each build to ensure that the glossary is complete and that links / anchors in the resulting Markdown file will all work.

**All entries:**

- Have a type of either "term" or "acronym"

**Terms:**

- Have a `description` attribute that either has content or is explicitly `null` (for terms that need no definition)
- Cross-referenced terms exist elsewhere in the glossary
- Have no extra attributes

**Acronyms:**

- Must list at least one linked entry that exists in the glossary
- Have no extra attributes

## Roadmap

We plan to redirect `@charlie define <term>` to this glossary in favor of the archived glossary.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
