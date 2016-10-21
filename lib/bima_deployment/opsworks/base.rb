module BimaDeployment
  module Opsworks
    class Base
      def client
        @client ||= self.class.client
      end

      def self.client
        return @client if defined?(@client)
        @client = ::Aws::OpsWorks::Client.new(region: region)
      end

      def self.region
        'us-east-1'
      end
    end
  end
end
