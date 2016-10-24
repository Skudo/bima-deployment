module BimaDeployment
  module Opsworks
    class Configuration
      def self.load_credentials(profile = nil)
        return unless File.exists?(Aws.shared_config.config_path) ||
                      File.exists?(Aws.shared_config.credentials_path)

        begin
          profile ||= 'bima'
          shared_credentials = Aws::SharedCredentials.new(profile_name: profile)
        rescue Aws::Errors::NoSuchProfileError
          shared_credentials = Aws::SharedCredentials.new(profile_name: 'default')
        end

        Aws.config.update(credentials: shared_credentials.credentials)
      end
    end
  end
end
