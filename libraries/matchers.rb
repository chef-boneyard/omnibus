if defined?(ChefSpec)
  ChefSpec::Runner.define_runner_method :remote_install
  def install_remote_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:remote_install, :install, resource_name)
  end

  ChefSpec::Runner.define_runner_method :ruby_gem
  def install_ruby_gem(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ruby_gem, :install, resource_name)
  end

  ChefSpec::Runner.define_runner_method :ruby_install
  def install_ruby_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ruby_install, :install, resource_name)
  end
end
