module BimaDeployment
  module Opsworks
    class Stack
      attr_reader :client, :stack_id

      def self.find(stack_name:, client:)
        response = client.describe_stacks
        stack = response.stacks.find { |stack| stack.name == stack_name }
        return nil if stack.nil?

        new(stack.stack_id, client)
      end

      def initialize(stack_id, client)
        @stack_id = stack_id
        @client = client
        fetch
      end

      def fetch
        response = client.describe_stacks(stack_ids: [stack_id])
        @data = response.stacks[0]
      end

      def name
        @data.name
      end
    end
  end
end
