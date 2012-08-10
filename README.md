# Guard::Motion [![Build Status](https://secure.travis-ci.org/mordaroso/guard-motion.png?branch=master)](http://travis-ci.org/mordaroso/guard-motion)

Motion guard allows to automatically & intelligently launch [RubyMotion](http://www.rubymotion.com/) specs when files are modified.

## Install

Please be sure to have [Guard](https://github.com/guard/guard) installed before continue.

Install the gem:

```
$ gem install guard-motion
```

Add it to your Gemfile (inside development group):

``` ruby
gem 'guard-motion'
```

Add guard definition to your Guardfile by running this command:

```
$ guard init motion
```

Make sure Guard::Motion is loaded in your project Rakefile:

``` ruby
require 'guard/motion'
```

## Usage

Please read [Guard usage doc](https://github.com/guard/guard#readme)

## Guardfile

Motion guard can be really adapted to all kind of project setup.

### Typical RubyMotion App

``` ruby
guard 'motion' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
end
```

### Typical RubyMotion library

``` ruby
guard 'motion' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/[^/]+/(.+)\.rb$})     { |m| "./spec/#{m[1]}_spec.rb" }
end
```

Please read [Guard doc](https://github.com/guard/guard#readme) for more information about the Guardfile DSL.

## Options

By default, Guard::Motion will only look for spec files within `spec` in your project root. You can configure Guard::Motion to look in additional paths by using the `:spec_paths` option:

``` ruby
guard 'motion', :spec_paths => ["spec", "vendor/other_project/spec"] do
  # ...
end
```
If you have only one path to look, you can configure `:spec_paths` option with a string:

``` ruby
guard 'motion', :spec_paths => "test" do
  # ...
end
```

### List of available options:

``` ruby
:bundler => false            # use "bundle exec" to run the rake command, default: true
:binstubs => true            # use "bin/rake" to run the rake command (takes precedence over :bundle), default: false
:notification => false       # display Growl (or Libnotify) notification after the specs are done running, default: true
:all_after_pass => false     # run all specs after changed specs pass, default: true
:all_on_start => false       # run all the specs at startup, default: true
:keep_failed => false        # keep failed specs until they pass, default: true
:spec_paths => ["spec"]      # specify an array of paths that contain spec files
```

You can also use a custom binstubs directory using `:binstubs => 'some-dir'`.

Development
-----------

* Source hosted at [GitHub](https://github.com/mordaroso/guard-motion)
* Report issues/Questions/Feature requests on [GitHub Issues](https://github.com/mordaroso/guard-motion/issues)

Pull requests are very welcome! Make sure your patches are well tested. Please create a topic branch for every separate change
you make.
