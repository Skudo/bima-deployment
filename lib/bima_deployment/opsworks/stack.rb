module BimaDeployment
  module Opsworks
    class Stack < Base
      attr_reader :stack_id

      def self.find(stack_name:)
        response = client.describe_stacks
        stack = response.stacks.find { |stack| stack.name == stack_name }
        return nil if stack.nil?

        new(stack.stack_id)
      end

      def initialize(stack_id)
        @stack_id = stack_id
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
