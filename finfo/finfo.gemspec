Gem::Specification.new do |spec|
  spec.name          = "finfo"
  spec.version       = "0.1.0"
  spec.summary       = "Display file information and detect duplicate files"
  spec.author        = "ikeda"
  spec.files         = Dir["lib/**/*.rb", "bin/*"]
  spec.executables   = ["finfo"]
  spec.require_paths = ["lib"]
end
