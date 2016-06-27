require 'cucumber'
require 'flatware/cucumber/checkpoint'
require 'flatware/cucumber/formatter'
require 'flatware/cucumber/result'
require 'flatware/cucumber/runtime'
require 'flatware/cucumber/scenario_decorator'
require 'flatware/cucumber/scenario_result'
require 'flatware/cucumber/step_result'
require 'flatware/formatters/cucumber/console'

module Flatware
  module Cucumber

    extend self

    attr_reader :args, :jobs, :raw_args

    def configure(args=[], out_stream=$stdout, error_stream=$stderr)
      @raw_args = args.dup
      @args = args
      config = ::Cucumber::Cli::Configuration.new(out_stream, error_stream)
      config.parse! args

      config
    end

    def has_feature_files?(config)
      (config.feature_files - config.feature_dirs).any?
    end

    def extract_jobs_from_config(config)
      options = raw_args - args
      @jobs = config.feature_files.map { |file| Job.new file, options }.to_a
    end

    def run(feature_files=[], options=[])
      runtime.run feature_files, options
    end

    def runtime
      @runtime ||= Runtime.new
    end
  end
end
