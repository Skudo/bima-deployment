module BimaDeployment
  module Strategies
    module Opsworks
      class Base
        attr_accessor :git_tag, :logger
        attr_reader :environment
        attr_reader :status

        def initialize(environment, git_tag)
          @environment = environment
          @git_tag = git_tag
          @logger = BimaDeployment.config.logger
          @deployment = nil
        end

        def confirm(current_revision)
          last_deployment = BimaDeployment::Opsworks::Deployment.last(app: app)
          user = last_deployment.user
          timestamp = DateTime.parse(last_deployment.created_at)

          puts "Current source on OpsWorks: #{current_revision}"
          puts "Last deployment made by #{user} on #{timestamp.rfc822}."

          print "Continue with your deployment of \"#{git_tag}\"? [Y/n] "
          loop do
            input = STDIN.gets.chomp
            case input.downcase
              when 'n'
                exit 0
              when 'y'
                break
              when ''
                break
              else
            end
          end
        end

        def deploy
          @deployment = BimaDeployment::Opsworks::Deployment.create(stack: stack,
                                                                    app: app,
                                                                    comment: "\"#{git_tag}\", powered by rake task.")
          logger.info("Deploying ref \"#{git_tag}\" on #{environment}.")
          poll_until_done
        end

        def notify
          return unless status == 'successful'
          return if @deployment.nil?

          notification_config = BimaDeployment.config.notification || {}
          notification_config.each_pair do |service, service_configuration|
            next unless service_configuration[:enabled]
            notifier_class = "BimaDeployment::Notifications::#{service.camelcase}"
            next unless Object.const_defined?(notifier_class)

            notifier = notifier_class.constantize.new(service_configuration)
            notifier.notify(@deployment.user, app_name, git_tag, @deployment.url)
          end
        end

        protected

        def config
          BimaDeployment.config.deployment || {}
        end

        def stack_name
          config[:stack]
        end

        def stack
          return @stack if defined?(@stack)
          @stack = BimaDeployment::Opsworks::Stack.find(stack_name: stack_name)
        end

        def app_name
          config[:app]
        end

        def app
          return @app if defined?(@app)
          @app = BimaDeployment::Opsworks::App.find(stack: stack, app_name: app_name)
        end

        def poll_until_done
          result = nil

          loop do
            @deployment.fetch
            @status = @deployment.status
            case status
              when 'running'
                print '.'
                sleep 2
              else
                print "\n"
                prefix = case status
                           when 'successful'
                             result = true
                             '[SUCCESS]'
                           when 'failed'
                             result = false
                             '[FAIL]'
                           else
                             result = false
                             '[UNKNOWN]'
                         end

                @deployment.fetch
                logger.info("#{prefix} Finished deploying \"#{git_tag}\" on #{environment} in #{@deployment.duration} seconds.")
                logger.info("#{prefix} Find more info at: #{@deployment.url}")
                `open "#{@deployment.url}"` unless status == 'successful'
                break
            end
          end

          result
        end
      end
    end
  end
end
