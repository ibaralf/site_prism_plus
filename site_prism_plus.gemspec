
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "site_prism_plus/version"

Gem::Specification.new do |spec|
  spec.name          = "site_prism_plus"
  spec.version       = SitePrismPlus::VERSION
  spec.required_ruby_version = '>= 2.1'
  spec.platform    = Gem::Platform::RUBY
  spec.authors       = ["Ibarra Alfonso"]
  spec.email         = ["ibarraalfonso@gmail.com"]

  spec.summary       = %q{Extends site_prism gem with methods for robust tests and collect test metrics }
  spec.description   = %q{Adds more robust methods and collects test metrics. .}
  spec.homepage      = "https://github.com/ibaralf/site_prism_plus"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "site_prism", "~> 2.10"

  # NOTE: breaking with pry seems to affect webdriver that it could
  #       not find the elements in the current window
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "selenium-webdriver", ['>= 3.4.0', '<= 3.10.0']
  spec.add_development_dependency "chromedriver-helper", "~> 1.2.0"
  spec.add_development_dependency "pry", "~> 0.11.0"
end
