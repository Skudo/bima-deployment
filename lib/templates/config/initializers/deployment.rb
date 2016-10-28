deployment_config = Rails.application.config_for(:deployment).with_indifferent_access

BimaDeployment.configure do |config|
  config.deployment = deployment_config[:deployment]
  config.notification = deployment_config[:notification]
end
