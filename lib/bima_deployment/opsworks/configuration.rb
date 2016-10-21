module BimaDeployment
  module Opsworks
    class Configuration
      def self.load_credentials
        credentials_path = File.expand_path('~/.aws/credentials')
        config = {}.with_indifferent_access

        File.readlines(credentials_path).select { |line| line.starts_with?('aws') }.each do |line|
          key, value = line.split('=').map(&:strip)
          config[key] = value
        end

        set_credentials(config[:aws_access_key_id], config[:aws_secret_access_key])
      end

      protected

      def self.set_credentials(access_key, secret_key)
        credentials = Aws::Credentials.new(access_key, secret_key)
        Aws.config.update(credentials: credentials)
      end
    end
  end
end
