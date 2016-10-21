module BimaDeployment
  if Object.const_defined?(:Rails) and Rails.const_defined?(:Railtie)
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
