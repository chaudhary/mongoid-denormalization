
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mongoid/denormalization/version"

Gem::Specification.new do |spec|
  spec.name          = "mongoid-denormalization"
  spec.version       = Mongoid::Denormalization::VERSION
  spec.authors       = ["Amit Chaudhary"]
  spec.email         = ["chaudharyamitiit2007@gmail.com"]

  spec.summary       = %q{Mongoid denormalization helper module}
  spec.description   = %q{Helper module for denormalizing association attributes in Mongoid models.}
  spec.homepage      = "http://github.com/chaudhary/mongoid-denormalization"
  spec.license       = "MIT"

  # # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # # to allow pushing to a single host or delete this section to allow pushing to any host.
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

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
