module BimaDeployment
  module Notifications
    class Base
      def initialize(options = {})
      end

      def notify(deployer, name, ref, url)
        raise 'Implement #notify.'
      end
    end
  end
end
