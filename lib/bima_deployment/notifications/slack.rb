module BimaDeployment
  module Notifications
    class Slack < Base
      attr_reader :webhook_url

      def initialize(options = {})
        super
        @webhook_uri = URI(options[:url])
        @template = options[:template]
      end

      def template
        @template || "%s just deployed `%s` on `%s`.\n\n%s"
      end

      def notify(deployer, name, ref, url)
        Net::HTTP.post_form(@webhook_uri, payload: payload(deployer, name, ref, url))
      end

      protected

      def payload(deployer, name, ref, url)
        {
          text: template % [deployer, ref, name, url]
        }.to_json
      end
    end
  end
end
