require 'aws-sdk'
require 'logger'
require 'rake'

require 'bima_deployment/version'
require 'bima_deployment/configuration'
require 'bima_deployment/deployment'
require 'bima_deployment/package'
require 'bima_deployment/rails'

require 'bima_deployment/notifications/base'
require 'bima_deployment/notifications/slack'

require 'bima_deployment/opsworks/app'
require 'bima_deployment/opsworks/configuration'
require 'bima_deployment/opsworks/deployment'
require 'bima_deployment/opsworks/stack'

require 'bima_deployment/strategies/opsworks/base'
require 'bima_deployment/strategies/opsworks/git'
require 'bima_deployment/strategies/opsworks/s3'

module BimaDeployment
  mattr_accessor :config

  def self.configure
    self.config ||= Configuration.new
    yield self.config
  end

  def self.load_configuration(environment = 'development')
    return  unless defined?(Rails)

    yaml_path = Rails.root.join('config', 'deployment.yml')
    if File.exists?(yaml_path)
      deployment_config = YAML.load(File.read(yaml_path)).with_indifferent_access
      deployment_config = deployment_config[environment] || {}

      self.configure do |config|
        config.deployment = deployment_config[:deployment]
        config.notification = deployment_config[:notification]
      end
    end

    initializer_path = Rails.root.join('config', 'initializers', self.config.configuration_file)
    if File.exists?(initializer_path)
      puts "Using deployment configuration from #{initializer_path}"
      require initializer_path
    else
      puts "No deployment configuration found => using defaults"
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

  BimaDeployment::Opsworks::Configuration.load_credentials
end
