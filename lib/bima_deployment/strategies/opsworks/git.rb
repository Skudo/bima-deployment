module BimaDeployment
  module Strategies
    module Opsworks
      class Git < Base
        def confirm(*)
          super(app.app_source.revision)
        end

        def deploy
          app.app_source = { revision: git_tag } if app.app_source.revision != git_tag
          super
        end
      end
    end
  end
end
