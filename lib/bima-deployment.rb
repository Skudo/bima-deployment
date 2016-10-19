require 'aws-sdk'
require 'logger'
require 'rake'

require 'bima_deployment/version'
require 'bima_deployment/configuration'
require 'bima_deployment/package'
require 'bima_deployment/rails'

module BimaDeployment
  mattr_accessor :config

  def self.configure
    self.config ||= Configuration.new
    yield self.config
  end

  def self.load_configuration
    return  unless defined?(Rails)

    filepath = Rails.root.join('config', 'initializers', self.config.configuration_file)
    if File.exist?(filepath)
      puts "Using deploment configuration from #{filepath}"
      require filepath
    else
      puts "No deploment configuration found => using defaults"
    end
  end

  #
  # Initial configuration
  #
  logger = ::Logger.new(STDOUT)
  logger.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
  end
  config = Configuration.new
  config.logger = logger
  config.configuration_file = 'deployment.rb'
  config.s3 = {
    bucket_name: 'bima-releases-ireland',
    region: 'eu-west-1'
  }

  config.included = %w()

  config.excluded = %w(
    config/settings.yml
    config/aws.yml
    config/crm.yml
    config/database.yml
    .gitignore
    .travis.yml
    .rspec
    .git
    client/node_modules
    spec
    test
  )

  self.config = config
end
