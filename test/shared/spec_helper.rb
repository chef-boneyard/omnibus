require 'serverspec'

# Required by serverspec
set :backend, :exec

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require_relative(file) }

set :path, '/sbin:/usr/local/sbin:/usr/bin:/bin'

def home_dir
  if os[:family] == 'darwin'
    '/Users/omnibus'
  else
    '/home/omnibus'
  end
end
