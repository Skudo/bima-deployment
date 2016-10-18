module BimaDeployment
  module Strategies
    module Opsworks
      class Git < Base
        def deploy
          app.app_source = { revision: git_tag } if app.app_source.revision != git_tag
          super
        end
      end
    end
  end
end
