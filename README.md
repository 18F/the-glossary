# The Procurement Glossary

The procurement glossary is a set of definitions for common abbreviations and jargon found in the procurement lifecycle.

Definitions may not be expansive but should give users enough context to conduct further research and discovery. Although it typically focuses on procurement terms, some technical material may be included.

## Contributing

Open an issue to either [add an acronym]() or [add a term]().

Or, add the acronym / term to the glossary.yml file directly and open a pull request.

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
