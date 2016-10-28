module BimaDeployment
  if Object.const_defined?(:Rails)
    class InstallGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../../templates', __FILE__)

      def copy_files
        config_files = %w(
          config/deployment.yml
          config/initializers/deployment.rb
        )
        config_files.each do |config_file|
          copy_file(config_file)
          gsub_file(config_file, 'STACK', name)
          gsub_file(config_file, 'APP', name.downcase)
        end
      end
    end

    if Rails.const_defined?(:Railtie)
      # @private
      class Railtie < Rails::Railtie
        rake_tasks do
          load 'tasks/deploy.rake'
          load 'tasks/package.rake'
        end

        initializer 'bima_deployment.initialize' do |app|
        end
      end
    end
  end
end
