# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'generic-ruby-api-client/version'

Gem::Specification.new do |gem|
  gem.authors               = ['Avant']
  gem.email                 = ['dev@avant.com']
  gem.description           = "interface to build quick api client libraries/gems for our microservices"
  gem.summary               = 'Generic Ruby API Client'
  gem.homepage              = 'http://avant.com'

  gem.required_ruby_version = '>= 2.2.2'
  gem.files                 = `git ls-files`.split("\n")
  gem.test_files            = gem.files.grep(%r{^(test|spec|features)/})
  gem.name                  = 'generic-ruby-api-client'
  gem.require_paths         = ['lib']
  gem.version               = GenericRubyApiClient::VERSION

  gem.add_dependency('httparty')
  gem.add_dependency('addressable')
  gem.add_dependency('activesupport')
  gem.add_dependency('activemodel')
end
