# :exclamation: Notice

This thing is INCOMPLETE!

The main idea here was to use
- **Agents/GenServer** for running tasks, reporting errors, ...
- **Tasks** for indexing the files' contents parallelly
- **Streams** for feeding back from the discovery of files in the tree automatically and putting it into a queue for scheduling the tasks.
- **VIA Tuple Registry** for getting a hold of each individual process and make them able to adress each other

After all of that, it would generate a SQLite database (probably with Ecto) and tie it into a Docset, in one big package.

# DocsetGenerator

A scripting executable tool to convert ExDoc generated HTML documentation to the Dash format.

# TODO
## Chores
- [] Fixtures for a sample generated ExDoc documentation

## Persistence
- [] SQLite adapter setup
- [] Ecto schema to map entries to SQLite database tables
- [] Tests for generating a sample database

## Entry-matching
- [] Tests for Regex-matching:
  - [ ] Types
  - [ ] Callbacks
  - [ ] Functions
  - [ ] Behaviours
  - [ ] Exceptions
  - [ ] Modules
  - [ ] Guides
