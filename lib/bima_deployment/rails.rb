module BimaDeployment
  if Object.const_defined?(:Rails)
    class InstallGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../../templates', __FILE__)

      class_option :strategy, type: :string, default: 'opsworks/s3'
      class_option :slack, type: :string, default: 'https://hooks.slack.com/services/get-your-own-url'

      def copy_files
        config_files = %w(
          config/deployment.yml
          config/initializers/deployment.rb
        )
        replacements = {
          STACK: name,
          APP: name.downcase,
          STRATEGY: options[:strategy],
          SLACK_URL: options[:slack]
        }
        config_files.each do |config_file|
          copy_file(config_file)
          replacements.each_pair do |key, value|
            gsub_file(config_file, key.to_s, value.to_s)
          end
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
