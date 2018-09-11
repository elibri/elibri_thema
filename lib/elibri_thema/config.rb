require 'pathname'

module ElibriThema
  class Config

    class << self
      attr_accessor :root
    end

    #defaults - could be overriden using setup block
    self.root = Pathname.new(File.dirname(File.expand_path('../..', __FILE__)))

    def self.setup(&block)
      yield self
    end

    def initialize
      #copy all class variables into instance
      self.class.instance_variables.each do |var|
        instance_variable_set var, self.class.instance_variable_get(var)
        self.class.send :attr_accessor, var.to_s.gsub(/@/, '').to_sym
      end
    end
  end
end
