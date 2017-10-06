[![CircleCI](https://circleci.com/gh/DCORP-BV/tokens.svg?style=svg&circle-token=5d7155f6a4ce7248d345dbe9200f1abed868a8e9)](https://circleci.com/gh/DCORP-BV/tokens)
[![Build Status](https://circleci.com/gh/DCORP-BV/tokens.svg?style=shield&circle-token=5d7155f6a4ce7248d345dbe9200f1abed868a8e9)](https://circleci.com/gh/DCORP-BV/dcorp/)
[![JavaScript Style
Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://standardjs.com)

[Latest Coverage
Report](https://circleci.com/api/v1.1/project/github/DCORP-BV/dcorp/latest/artifacts/0/home/ubuntu/dcorp/coverage/index.html?branch=master).
**Note**: this links to the latest report for the **master branch**, which is
not necessarily associated with the current branch.

# Welcome to the DCORP Token-changer repository

## Preparing development environment

1. `git clone` this repository.
2. Install Docker. This is needed to run the Test RCP client in an isolated
   environment.
2. Install Node Package Manager (NPM). See [installation
   instructions](https://www.npmjs.com/get-npm)
3. Install the Solidity Compiler (`solc`). See [installation
   instructions](http://solidity.readthedocs.io/en/develop/installing-solidity.html).
4. Run `npm install` to install project dependencies from `package.json`.

## Dependency Management

NPM dependencies are defined in `package.json`.
This makes it easy for all developers to use the same versions of dependencies,
instead of relying on globally installed dependencies using `npm install -g`.

To add a new dependency, execute `npm install --save-dev [package_name]`. This
adds a new entry to `package.json`. Make sure you commit this change.

## Code Style

### Solidity

We strive to adhere to the [Solidity Style
Guide](http://solidity.readthedocs.io/en/latest/style-guide.html) as much as
possible. The [Solium](https://github.com/duaraghav8/Solium)
linter has been added to check code against this Style Guide. The linter is run
automatically by Continuous Integration.

### Javascript

For plain Javascript files (e.g. tests), the [Javascript Standard
Style](https://standardjs.com/) is used. There are several
[plugins](https://standardjs.com/#are-there-text-editor-plugins) available for
widely-used editors. These also support automatic fixing. This linter is run
automatically by Continuous Integration.

## Run tests, linter, etc.

- **Linter**: run `npm run linter`. See Section Code Style.
- **Test Linter**: run `npm run test-linter`. This runs the `standard` linter on
  all files in the test directory. See Section Code Style.
- **Test Linter Fix**: run `npm run test-linter-autofix`.
  This will run the `standard` linter in `--fix` mode. Many, but not all, errors
  can be fixed automatically.
- **Tests**: To run tests in the `test` directory, follow these steps:
  - Run `npm testrpc_boot` **once**. This starts an Ethereum client for testing.
    See [testrpc](https://github.com/ethereumjs/testrpc) for more information.
  - Run `npm test` to run the tests as often as you need.
- **Code Coverage**: `npm run coverage`. This runs
  [solidity-coverage](https://github.com/sc-forks/solidity-coverage).
  You need to stop all instances of
  `testrpc` first. Coverage report will be generated in `/coverage`. The
  coverage report for the latest build is also accessible through the link at
  the top of this page.

## Continuous Integration

This repository has been set up for Continuous Integration. This means that
tests, linters, code coverage, etc. are automatically executed after every commit.
[CircleCI](https://circleci.com/gh/DCORP-BV/dcorp) has
been setup to serve as a CI server for this project.
