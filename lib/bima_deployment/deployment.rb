module BimaDeployment
  class Deployment
    attr_accessor :git_tag, :logger
    attr_reader :environment

    def initialize(environment, git_tag, strategy = nil)
      @environment = environment
      @git_tag = git_tag
      @strategy = strategy unless strategy.nil?
      @logger = BimaDeployment.config.logger
    end

    def confirm
      strategy.confirm
    end

    def deploy
      strategy.deploy
    end

    def notify
      strategy.notify
    end

    protected

    def strategy
      return @strategy if defined?(@strategy)

      strategy_name = BimaDeployment.config.strategy
      strategy = "bima_deployment/strategies/#{strategy_name}".camelcase
      raise "Unknown deployment strategy: #{strategy_name}" unless Object.const_defined?(strategy)

      @strategy = strategy.constantize.new(environment, git_tag)
    end
  end
end
