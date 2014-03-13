if defined?(ChefSpec)
  def install_remote_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:remote_install, :install, resource_name)
  end

  def install_ruby_gem(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ruby_gem, :install, resource_name)
  end

  def install_ruby_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ruby_install, :install, resource_name)
  end
end
