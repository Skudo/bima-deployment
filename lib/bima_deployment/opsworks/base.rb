module BimaDeployment
  module Opsworks
    class Base
      def client
        @client ||= self.class.client
      end

      def self.client
        @client ||= if defined?(Aws)
                      ::Aws::OpsWorks::Client.new(region: region)
                    elsif defined?(AWS)
                      ::AWS::OpsWorks::Client.new(region: region)
                    end
      end

      def self.region
        'us-east-1'
      end
    end
  end
end
