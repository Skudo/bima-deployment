module BimaDeployment
  class Package
    attr_accessor :git_tag, :logger
    attr_reader   :included, :excluded

    def self.package_dir(base_dir = git_repository)
      File.join(base_dir, 'tmp', 'package')
    end

    def self.releases_dir(base_dir = git_repository)
      File.join(base_dir, 'tmp', 'releases')
    end

    def self.git_repository
      `git rev-parse --show-toplevel`.strip
    end

    def initialize(git_tag)
      @git_tag = git_tag
      @logger = BimaDeployment.config.logger

      @package_archive = "#{@git_tag}.tbz2".gsub('/','-')
      @git_repository = `git rev-parse --show-toplevel`.strip

      bucket_name = BimaDeployment.config.s3[:bucket_name]
      region = BimaDeployment.config.s3[:region]
      @s3_bucket = Aws::S3::Bucket.new(bucket_name, region: region)

      @included = BimaDeployment.config.package[:included] || []
      @excluded = BimaDeployment.config.package[:excluded] || []
    end

    def package_dir
      self.class.package_dir(git_repository)
    end

    def releases_dir
      self.class.releases_dir(git_repository)
    end

    def release_path
      File.join(releases_dir, package_archive)
    end

    def s3_url
      "https://#{s3_bucket.name}.s3.amazonaws.com/#{s3_object_key}"
    end

    def client_app?
      path = File.join(git_repository, 'client', 'package.json')
      File.exists?(path)
    end

    def release?
      !!(git_tag =~ /^[[:digit:]]+\.[[:digit:]]+(\.[[:digit:]]+)?$/)
    end

    def build
      FileUtils.rm_rf(package_dir)
      FileUtils.mkdir_p(package_dir)
      FileUtils.mkdir_p(releases_dir)

      Dir.chdir(package_dir) do
        sh "rsync -a #{git_repository}/.git ."
        sh "git reset --hard #{git_tag}"
        sh "rsync -a #{git_repository}/client/node_modules client/." if client_app?

        Bundler.with_clean_env do
          sh "bundle install --quiet --without development test"
          sh 'bundle package --quiet'
        end

        if client_app?
          sh 'cd client && npm install > /dev/null'
          sh 'cd client && grunt build --json > /dev/null'
        end
      end

      # include files or directories
      included.each do |name|
        src = File.join(git_repository, name)
        dest = File.join(package_dir, name)

        if File.exists?(src)
          if File.file?(src)
            FileUtils.cp(src, dest)
          else
            FileUtils.cp_r(src, dest)
          end
        end
      end

      # excluded files and directories
      excluded.each do |name|
        path = File.join(package_dir, name)

        if File.exists?(path)
          if File.file?(path)
            File.delete(path)
          else
            FileUtils.remove_dir(path)
          end
        end
      end

      sh "cd #{package_dir} && tar cjf #{release_path} ."
      FileUtils.rm_rf(package_dir)
    end

    def upload(options = {})
      s3_object = s3_bucket.object(s3_object_key)

      logger.info "Writing to s3://#{s3_object.bucket.name}/#{s3_object.key} ..."
      raise "Package file #{release_path} is empty." unless File.size?(release_path)

      metadata = options[:metadata] || {}
      metadata.reverse_merge!(
        commit: git_rev,
        package_date: Time.now.iso8601,
        upload_user: username
      ).stringify_keys

      logger.info "Uploading #{release_path} (#{File.size(release_path) / 1024**2 } MB) ..."
      start_time = Time.now
      s3_options = {
        content_type: "application/x-bzip2",
        metadata: metadata,
        server_side_encryption: 'AES256',
      }

      if s3_object.upload_file(release_path, s3_options)
        logger.info "... finished in #{(Time.now - start_time).to_i} seconds."
        true
      else
        logger.info "... failed."
        false
      end
    end


    private

    attr_reader :git_repository, :package_archive, :s3_bucket

    def username
      `whoami`.strip
    end

    def git_rev
      `git rev-parse #{git_tag}`.strip
    end

    def s3_object_key
      git_repository_name = File.basename(git_repository)
      dirname = release? ? 'releases' : 'branches'
      "#{git_repository_name}/#{dirname}/#{package_archive}"
    end

    def sh(command, options = {})
      options[:verbose] ||= true

      logger.info(command) if options[:verbose]
      %x(#{command})
    end
  end
end
