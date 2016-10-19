namespace :package do
  directory BimaDeployment::Package.releases_dir

  task :build, [:git_tag] do |_, args|
    package = BimaDeployment::Package.new(args[:git_tag])
    package.build
  end

  task :upload, [:git_tag] do |_, args|
    package = BimaDeployment::Package.new(args[:git_tag])
    package.upload
  end

  task :cleanup, [:git_tag] do |_, _|
    rm_rf BimaDeployment::Package.package_dir, verbose: false
    rm_rf BimaDeployment::Package.releases_dir, verbose: false
  end
end

desc "Package the app and upload to S3"
task :package, [:git_tag] do |_, args|
  git_tag = args[:git_tag] || 'master'

  BimaDeployment.load_configuration
  %w(
    package:build
    package:upload
    package:cleanup
  ).each do |task|
    Rake::Task[task].invoke(git_tag)
  end
end
