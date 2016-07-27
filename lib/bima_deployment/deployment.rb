module BimaDeployment
  class Deployment
    attr_accessor :git_tag, :logger
    attr_reader :whoami, :package_archive, :s3_bucket

    def initialize(git_tag:)
      @git_tag = git_tag
      @logger = BimaDeployment.logger

      @whoami = %x(whoami).strip
      @package_archive = "#{@git_tag}.tbz2".gsub('/','-')

      bucket_name = BimaDeployment.s3[:bucket_name]
      region = BimaDeployment.s3[:region]
      @s3_bucket ||= Aws::S3::Bucket.new(bucket_name, region: region)
    end

    def git_repo_dir
      `git rev-parse --show-toplevel`.strip
    end

    def git_repo_name
      File.basename(self.git_repo_dir)
    end

    def git_rev
      `git rev-parse HEAD`.strip
    end

    def info_now
      Time.now.iso8601
    end

    def client_app?
      filepath = File.join(git_repo_dir, 'client', 'package.json')
      File.exists?(filepath)
    end

    def upload(s3_object, file_path, options = {})
      logger.info "Writing to s3://#{s3_object.bucket.name}/#{s3_object.key}"
      raise "Package file #{file_path} is empty" unless File.size?(file_path)

      metadata = options[:metadata] || {
        commit: self.git_rev,
        package_date: self.info_now,
        upload_user: self.whoami,
      }.stringify_keys

      logger.info "Uploading #{file_path} (#{File.size(file_path) / 1024 / 1024 } MB)"
      start_time = Time.now
      s3_options = {
        content_type: "application/x-bzip2",
        metadata: metadata,
        server_side_encryption: 'AES256',
      }

      if s3_object.upload_file(file_path, s3_options)
        logger.info "... finished in #{(Time.now - start_time).to_i}s."
        logger.info "Use 'https://#{s3_bucket.name}.s3.amazonaws.com/#{s3_object.key}' as Repository URL in OpsWorks"
      else
        logger.info "... failed."
      end
    end
  end
end
