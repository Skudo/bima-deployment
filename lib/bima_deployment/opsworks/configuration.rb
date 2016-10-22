module BimaDeployment
  module Opsworks
    class Configuration
      def self.load_credentials
        begin
          shared_credentials = Aws::SharedCredentials.new(profile_name: 'bima')
        rescue Aws::Errors::NoSuchProfileError
          shared_credentials = Aws::SharedCredentials.new(profile_name: 'default')
        end

        Aws.config.update(credentials: shared_credentials.credentials)
      end

      protected

      def self.set_credentials(access_key, secret_key)
        credentials = Aws::Credentials.new(access_key, secret_key)
        Aws.config.update(credentials: credentials)
      end
    end
  end
end
