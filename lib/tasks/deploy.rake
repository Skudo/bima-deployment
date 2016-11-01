def default_git_tag
  `git rev-parse --abbrev-ref HEAD`.strip
end

namespace :deploy do
  %i(development staging production).each do |environment|
    desc "Deploy to #{environment} environment on OpsWorks."
    task environment, [:git_tag] do |_, args|
      BimaDeployment.load_configuration(environment)
      git_tag = args[:git_tag] || default_git_tag
      deployment = BimaDeployment::Deployment.new(environment, git_tag)
      deployment.confirm
      deployment.deploy
      deployment.notify
    end
  end
end

task :deploy, [:git_tag] do |_, args|
  git_tag = args[:git_tag] || default_git_tag
  Rake::Task['deploy:development'].invoke(git_tag)
end
