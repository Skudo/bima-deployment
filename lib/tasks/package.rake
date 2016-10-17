def tmp_package_dir
  File.join(`git rev-parse --show-toplevel`.strip, 'tmp', 'package')
end

def tmp_release_dir
  File.join(`git rev-parse --show-toplevel`.strip, 'tmp', 'release')
end

namespace :package do
  directory tmp_release_dir

  task tmp_package_dir do
    rm_rf tmp_package_dir, verbose: false
    mkdir_p tmp_package_dir, verbose: false
  end

  task :build, [:git_tag] => [tmp_release_dir, tmp_package_dir] do |t, args|
    dpl = BimaDeployment::Deployment.new(git_tag: args[:git_tag])

    Dir.chdir(tmp_package_dir) do
      sh %!rsync -a #{dpl.git_repo_dir}/.git .!
      sh %!git reset --hard #{dpl.git_tag}!
      sh %!rsync -a #{dpl.git_repo_dir}/client/node_modules client/.!  if dpl.client_app?

      Bundler.with_clean_env do
        sh %!bundle install --quiet --without development test!
        sh %!bundle package --quiet!
      end

      if dpl.client_app?
        sh "cd client && npm install > /dev/null"
        sh "cd client && grunt build --json > /dev/null"
      end
    end

    # include files or directories
    BimaDeployment.included.each do |name|
      src = File.join(dpl.git_repo_dir, name)
      dest = File.join(tmp_package_dir, name)

      if File.exists?(src) && File.file?(src)
        cp src, dest, verbose: true
      else
        cp_r src, dest, verbose: true
      end
    end

    # excluded files and directories
    BimaDeployment.excluded.each do |name|
      filepath = File.join(tmp_package_dir, name)

      if File.exists?(filepath) && File.file?(filepath)
        rm filepath, verbose: false
      else
        rm_rf filepath, verbose: false
      end
    end
  end

  task :upload, [:git_tag] do |t, args|
    dpl = BimaDeployment::Deployment.new(git_tag: args[:git_tag])
    package_path = "#{tmp_release_dir}/#{dpl.package_archive}"
    dirname = 'branches'
    dirname = 'releases'  if dpl.git_tag =~ /^[[:digit:]]+\.[[:digit:]]+(\.[[:digit:]]+)?$/
    release_obj = dpl.s3_bucket.object("#{dpl.git_repo_name}/#{dirname}/#{dpl.package_archive}")

    sh "cd #{tmp_package_dir} && tar cjf #{package_path} ."
    dpl.upload(release_obj, package_path)
  end

  task :clean_up, [:git_tag] do |t, args|
    rm_rf tmp_package_dir, verbose: false
    rm_rf tmp_release_dir, verbose: false
  end
end



desc "Package the app and upload to S3"
task :package, [:git_tag] do |t, args|
  git_tag = args[:git_tag] || 'master'

  BimaDeployment.load_configuration
  [
    "package:build",
    "package:upload",
    "package:clean_up"
  ].each do |task|
    Rake::Task[task].invoke(git_tag)
  end
end
