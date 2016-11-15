module BimaDeployment
  class Configuration
    attr_accessor :logger, :configuration_file
    attr_accessor :deployment, :notification, :package
    attr_accessor :s3
  end
end
