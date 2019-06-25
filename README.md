# Flatware [![Build Status][travis-badge]][travis] [![Code Climate][code-climate-badge]][code-climate]

[travis-badge]: https://travis-ci.org/briandunn/flatware.svg?branch=master
[travis]: http://travis-ci.org/briandunn/flatware
[code-climate-badge]: https://codeclimate.com/github/briandunn/flatware.png
[code-climate]: https://codeclimate.com/github/briandunn/flatware

Flatware parallelizes your test suite to significantly reduce test time.

### Flatware

Add the runners you need to your Gemfile:

```ruby
gem 'flatware-rspec', require: false    # one
gem 'flatware-cucumber', require: false # or both
```

then run

```sh
bundle install
```

## Usage

### Cucumber

To run your entire suite with the default cucumber options, add the `flatware-cucumber` gem and just:

```sh
$ flatware cucumber
```

### RSpec

To run your entire suite with the default rspec options add the `flatware-rspec` gem and just:

```sh
$ flatware rspec
```

The rspec runner can balance worker loads, making your suite even faster.

It forms balaced groups of spec files according to their last run times, if you've set `example_status_persistence_file_path` [in your RSpec config](https://relishapp.com/rspec/rspec-core/v/3-8/docs/command-line/only-failures).

For this to work the configuration option must be loaded before any specs are run. The `.rspec` file is one way to achive this:

    --require spec_helper

But beware, if you're using ActiveRecord in your suite you'll need to avoid doing things that cause it to establish a database connection in `spec_helper.rb`. If ActiveRecord connects before flatware forks off workers, each will die messily. All of this will just work if you're following [the recomended pattern of splitting your helpers into `spec_helper` and `rails_helper`](https://github.com/rspec/rspec-rails/blob/v3.8.2/lib/generators/rspec/install/templates/spec/rails_helper.rb).


### Options

If you'd like to limit the number of forked workers, you can pass the 'w' flag:

```sh
$ flatware -w 3
```

You can also pass most cucumber/rspec options to Flatware. For example, to run only
features that are not tagged 'javascript', you can:

```sh
$ flatware cucumber -t 'not @javascript'
```

Additionally, for either cucumber or rspec you can specify a directory:

```sh
$ flatware rspec spec/features
```

## Typical Usage in a Rails App

Add the following to your `config/database.yml`:

```yml
test:
  database: foo_test
```

becomes:

```yml
test:
  database: foo_test<%=ENV['TEST_ENV_NUMBER']%>
```

Run the following:

```sh
$ rake db:setup # if not already done
$ flatware fan rake db:test:prepare
```

Now you are ready to rock:

```sh
$ flatware rspec && flatware cucumber
```

## Planned Features

* Use heuristics to run your slowest tests first

## Design Goals

### Maintainable

* Fully test at an integration level. Don't be afraid to change the code. If you
  break it you'll know.
* Couple as loosely as possible, and only to the most stable/public bits of
  Cucumber and RSpec.

### Minimal

* Projects define their own preparation scripts
* Only distribute to local cores (for now)

### Robust

* Depend on a dedicated messaging library
* Be accountable for completed work; provide progress report regardless of
  completing the suite.

## Tinkering

Flatware integration tests use [aruba][a]. In order to get a demo cucumber project you
can add the `@no-clobber` tag to `features/flatware.feature` and run the test
with `cucumber features/flatware.feature`. Now you should have a `./tmp/aruba`
directory. CD there and `flatware` will be in your path so you can tinker away.

## How it works

Flatware relies on a message passing system to enable concurrency.
The main process declares a worker for each cpu in the computer. Each
worker forks from the main process and is then assigned a portion of the
test suite.  As the worker runs the test suite it sends progress
messages to the main process.  These messages are collected and when
the last worker is finished the main process provides a report on the
collected progress messages.

## Resources

[a]: https://github.com/cucumber/aruba

## Contributing to Flatware

Do whatever you want. I'd love to help make sure Flatware meets your needs.

## About

[![Hashrocket logo](https://hashrocket.com/hashrocket_logo.svg)](https://hashrocket.com)

Flatware is supported by the team at [Hashrocket](https://hashrocket.com), a multidisciplinary design & development consultancy. If you'd like to [work with us](https://hashrocket.com/contact-us/hire-us) or [join our team](https://hashrocket.com/contact-us/jobs), don't hesitate to get in touch.
