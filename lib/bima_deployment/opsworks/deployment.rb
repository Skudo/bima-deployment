module BimaDeployment
  module Opsworks
    class Deployment < Base
      attr_reader :deployment_id

      def self.create(stack:, app:, comment: '')
        deployment = client.create_deployment(stack_id: stack.stack_id,
                                              app_id: app.app_id,
                                              command: {
                                                name: 'deploy',
                                                args: {
                                                  'migrate' => ['false']
                                                }
                                              },
                                              comment: comment)
        new(deployment.deployment_id)
      end

      def self.last(app:)
        response = client.describe_deployments(app_id: app.app_id)
        last_deployment = response.deployments.first
        return nil if last_deployment.nil?

        new(last_deployment.deployment_id)
      end

      def initialize(deployment_id)
        @deployment_id = deployment_id
        fetch
      end

      def fetch
        response = client.describe_deployments(deployment_ids: [deployment_id])
        @data = response.deployments[0]
      end

      def url
        "https://console.aws.amazon.com/opsworks/home?region=eu-central-1&endpoint=us-east-1#/stack/#{@data.stack_id}/deployments/#{deployment_id}"
      end

      def user
        user_arn = @data.iam_user_arn
        user_arn.match(%r(user/(.*)))[1]
      end

      %i(created_at completed_at duration status).each do |method_name|
        define_method method_name do
          @data.send(method_name)
        end
      end
    end
  end
end
