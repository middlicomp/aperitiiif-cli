# aperitiiif-cli

gem-packaged commands for processing aperitiiif batches 🥂

[![rspec](https://github.com/middlicomp/aperitiiif-cli/actions/workflows/rspec.yml/badge.svg)](https://github.com/middlicomp/aperitiiif-cli/actions/workflows/rspec.yml) [![reek](https://github.com/middlicomp/aperitiiif-cli/actions/workflows/reek.yml/badge.svg)](https://github.com/middlicomp/aperitiiif-cli//actions/workflows/reek.yml) [![rubocop](https://github.com/middlicomp/aperitiiif-cli/actions/workflows/rubocop.yml/badge.svg)](https://github.com/middlicomp/aperitiiif-cli//actions/workflows/rubocop.yml)  

[![Maintainability](https://api.codeclimate.com/v1/badges/c25005f1fd12e7a86122/maintainability)](https://codeclimate.com/github/nyu-dss/aperitiiif/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/c25005f1fd12e7a86122/test_coverage)](https://codeclimate.com/github/nyu-dss/aperitiiif/test_coverage)

### Related repos:
- **[aperitiiif](https://github.com/middlicomp/aperitiiif)** : documentation for the project; publishes to [github pages](https://nyu-dss.github.io/aperitiiif)
- **[aperitiiif-batch-template](https://github.com/middlicomp/aperitiiif-batch-template)** : template repository for creating batches; includes github actions workflows, gem configs, and project scaffolding.

## Prerequisites
- [Ruby Version Manager](https://rvm.io/rvm/install)
- [Git](https://git-scm.com/downloads)
- [Vips](https://www.libvips.org/install.html)

## Installation

### Recommended

It is highly recommended that you use the [aperitiiif-batch-template](https://github.com/nyu-dss/aperitiiif-batch-template) repo to create your new batch project. This method will include all the necessary Ruby dependencies and project structure.

### Manual

Alternatively, you can add the gem to your project's Gemfile:

``` ruby
gem 'aperitiiif', github: 'nyu-dss/aperitiiif-cli'
```

Then install by running the command:

``` sh
bundle install
```

## Usage

After your batch project is set up and you have installed the dependencies using Bundler, you will have access to the `aperitiiif` commands.

1. Check available commands
  ```sh
  bundle exec aperitiiif --help
  ```
2. Check available batch commands
  ```sh
  bundle exec aperitiiif batch --help
  ```
  You will see something like:
  ```sh
  ➜ bundle exec aperitiiif batch --help
    Commands:
    aperitiiif batch build           # build batch resources
    aperitiiif batch help [COMMAND]  # Describe subcommands or one specific subc...
    aperitiiif batch lint            # lint the batch
    aperitiiif batch reset           # reset the batch
  ```

## Development

Contributions should:
- Avoid code smells
- Follow style guide
- Update tests as needed
- Update documentation as needed

To ensure the above, this repo includes configuration for [reek](https://github.com/troessner/reek) and [rubocop](https://github.com/rubocop/rubocop) as well as [rspec](https://rspec.info/) tests. You can run them respectively with the following commands:

```sh
bundle exec reek
```
```sh
bundle exec rubocop -A
```
```sh
bundle exec rspec
```
