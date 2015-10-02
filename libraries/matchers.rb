if defined?(ChefSpec)
  ChefSpec.define_matcher :remote_install
  def install_remote_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:remote_install, :install, resource_name)
  end

  ChefSpec.define_matcher :ruby_gem
  def install_ruby_gem(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ruby_gem, :install, resource_name)
  end

  ChefSpec.define_matcher :ruby_install
  def install_ruby_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ruby_install, :install, resource_name)
  end

  ChefSpec.define_matcher :omnibus_build
  def execute_omnibus_build(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_build, :execute, resource_name)
  end
end
