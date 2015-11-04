if defined?(ChefSpec)
  ChefSpec.define_matcher :omnibus_build
  def execute_omnibus_build(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:omnibus_build, :execute, resource_name)
  end
end
