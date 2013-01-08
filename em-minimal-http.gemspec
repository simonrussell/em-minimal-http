Gem::Specification.new do |s|
  s.name = "em-minimal-http"
  s.version = "0.0.1"
  s.summary = "A minimal web server for EventMachine"
  s.description = "A minimal, but production-ready web server that fits into your existing EventMachine app."
  
  s.author = "Simon Russell"
  s.email = "spam+em-minimal-http@bellyphant.com"
  s.homepage = "http://github.com/simonrussell/em-minimal-http"
  
  s.add_dependency 'eventmachine', '~> 1.0'
  s.add_dependency 'http_parser.rb', '~> 0.5'
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rack'
  
  s.required_ruby_version = '>= 1.9.3'
  
  s.files = Dir['lib/**/*.rb'] + ['LICENSE']
end
