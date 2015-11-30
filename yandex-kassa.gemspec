# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yandex_kassa/version'

Gem::Specification.new do |spec|
  spec.name          = "yandex-kassa"
  spec.version       = YandexKassa::VERSION
  spec.authors       = ["Sergey Odintsov"]
  spec.email         = ["nixx.dj@gmail.com"]

  spec.summary       = %q{Yandex.Kassa Rails}
  spec.description   = %q{Реализация протокола автоматизации массовых выплат}
  spec.homepage      = "https://github.com/PNixx/yandex-kassa"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
