require 'aws-sdk'
require 'logger'
require 'rake'

require 'bima_deployment/version'
require 'bima_deployment/deployment'
require 'bima_deployment/rails'

module BimaDeployment
  mattr_accessor :logger, :s3, :configuration_file
  mattr_accessor :excluded_files, :excluded_dirs

  def self.configure
    yield self
  end

  def self.load_configuration
    return  unless defined?(Rails)

    filepath = Rails.root.join('config', 'initializers', self.configuration_file)
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
  self.logger = logger
  self.configuration_file = 'deployment.rb'
  self.s3 = {
    bucket_name: 'bima-releases-ireland',
    region: 'eu-west-1'
  }

  self.excluded_files = %w(
    config/settings.yml
    config/aws.yml
    config/crm.yml
    config/database.yml
    .gitignore
    .travis.yml
    .rspec
  )
  self.excluded_dirs = %w(
    .git
    client/node_modules
    spec
    test
  )
end
