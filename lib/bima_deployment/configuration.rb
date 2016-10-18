module BimaDeployment
  class Configuration
    attr_accessor :logger, :configuration_file
    attr_accessor :strategy, :deployment, :notification
    attr_accessor :excluded, :included
    attr_accessor :s3
  end
end
