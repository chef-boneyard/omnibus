module RSpec
  module Core
    #
    module DSL
      def omnibus_build(pattern)
        Serverspec::Type::OmnibusBuild.new(pattern)
      end
    end
  end
end

extend RSpec::Core::DSL
Module.send(:include, RSpec::Core::DSL)
