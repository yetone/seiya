require './lib/seiya/version'

Gem::Specification.new do |s|
  s.name = 'seiya'
  s.version = Seiya::VERSION
  s.author = 'yetone'
  s.email = 'i@yetone.net'
  s.executables = ['seiya']
  s.homepage = 'https://github.com/yetone/seiya'
  s.summary = 'A ruby spider like scrapy-python'
  s.require_paths = ['lib']
  s.files = Dir.glob('{bin,lib,sample,test}/**/*') + ['README.md']
  s.license = 'WTFPL'
end
