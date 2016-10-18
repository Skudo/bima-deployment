module BimaDeployment
  module Strategies
    module Opsworks
      class S3 < Base
        def deploy
          package = BimaDeployment::Package.new(git_tag)
          package.build
          package.upload

          app.app_source = { url: package.s3_url } if app.app_source.url != package.s3_url
          super
        end
      end
    end
  end
end
