$:.push File.expand_path('../lib', __FILE__)
require 'bima_deployment/version'

Gem::Specification.new do |s|
  s.name        = 'bima-deployment'
  s.version     = BimaDeployment::VERSION
  s.authors     = ['Joergen Dahlke']
  s.email       = ['joergen.dahlke@infopark.de']
  s.homepage    = 'https://github.com/jdahlke/bima-deployment'
  s.summary     = %q{BImA deployment rake task.}
  s.description = %q{BImA deployment rake task.}

  s.rubyforge_project = 'bima-deployment'

  s.files         = `git ls-files -- lib/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here:
  s.add_dependency 'aws-sdk', '~> 2.0'
  s.add_dependency 'activesupport'

  # specify any development dependencies here:
  s.add_dependency 'rake'
end
