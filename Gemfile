source 'https://rubygems.org'

group :lint do
  gem 'foodcritic', '~> 4.0'
  gem 'rubocop', '~> 0.33'
  gem 'rake'
end

group :unit do
  gem 'berkshelf',  '~> 3.2'
  gem 'chefspec',   '~> 4.3'
end

group :kitchen_common do
  gem 'test-kitchen',    '~> 1.4'
  gem 'winrm-transport', '~> 1.0'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.18'
end

group :kitchen_cloud do
  gem 'kitchen-digitalocean'
  gem 'kitchen-ec2'
  gem 'kitchen-zone', git: 'git@github.com:scotthain/kitchen-zone.git'
end
