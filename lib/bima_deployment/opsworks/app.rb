module BimaDeployment
  module Opsworks
    class App
      attr_reader :client, :app_id

      def self.find(stack:, app_name:, client:)
        response = client.describe_apps(stack_id: stack.stack_id)
        app = response.apps.find { |app| app.name == app_name }
        return nil if app.nil?

        new(app.app_id, client)
      end

      def initialize(app_id, client)
        @app_id = app_id
        @client = client
        fetch
      end

      def fetch
        response = client.describe_apps(app_ids: [app_id])
        @data = response.apps[0]
      end

      def app_source
        @data.app_source
      end

      def app_source=(payload = {})
        client.update_app(app_id: app_id, app_source: payload)
      end
    end
  end
end
