$:.unshift File.dirname(__FILE__)

require 'reek/name'
require 'reek/code_context'
require 'reek/object_refs'

module Reek
  class MethodContext < CodeContext
    attr_reader :parameters, :local_variables, :instance_variables
    attr_reader :outer, :calls, :refs
    attr_reader :num_statements, :depends_on_self
    attr_accessor :name

    def initialize(outer, exp, record = true)
      super(outer, exp)
      @parameters = []
      @local_variables = []
      @instance_variables = []
      @name = Name.new(exp[1])
      @num_statements = 0
      @calls = Hash.new(0)
      @refs = ObjectRefs.new
      @outer.record_method(@name)    # TODO: should be children of outer?
    end

    def count_statements(num)
      @num_statements += num
    end

    def has_parameter(sym)
      parameters.include?(sym.to_s)
    end
    
    def constructor?
      @name.to_s == 'initialize'
    end
    
    def record_call_to(exp)
      @calls[exp] += 1
    end
    
    def record_depends_on_self
      @depends_on_self = true
    end

    def record_instance_variable(sym)
      @instance_variables << Name.new(sym)
    end

    def record_local_variable(sym)
      @local_variables << Name.new(sym)
    end

    def self.is_block_arg?(param)
      Array === param and param[0] == :block
    end

    def record_parameter(param)
      @parameters << Name.new(param) unless MethodContext.is_block_arg?(param)
    end

    def outer_name
      "#{@outer.outer_name}#{@name}/"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end

    def envious_receivers
      return [] if constructor? or @refs.self_is_max?
      @refs.max_keys
    end
  end
end
