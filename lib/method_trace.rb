require 'rubygems'
require 'metafun'

module MethodTrace
  module MethodDefinition
    def self.definition_sites
      @definition_sites ||= {}
    end
    
    module InstanceMethods
      def method_added_with_method_definitions(method)
        method_added_without_method_definitions(method)
        name = "#{self.object_id}##{method}"
        MethodTrace::MethodDefinition.definition_sites[name] = caller
      end
    end

    def self.included(base)
      base.send :include, InstanceMethods
      base.instance_eval do
        alias_method :method_added_without_method_definitions, :method_added
        alias_method :method_added, :method_added_with_method_definitions
      end
    end
    
    def self.extended(base)
      base.extend InstanceMethods
      class << base
        alias_method :method_added_without_method_definitions, :method_added
        alias_method :method_added, :method_added_with_method_definitions
      end
    end
  end
  
  module SingletonMethodDefinition
    module InstanceMethods
      def singleton_method_added_with_method_definitions(method)
        singleton_method_added_without_method_definitions(method)
        name = "#{self.object_id}::#{method}"
        MethodTrace::MethodDefinition.definition_sites[name] = caller
      end
    end
    
    def self.included(base)
      base.send :include, InstanceMethods
      base.instance_eval do
        alias_method :singleton_method_added_without_method_definitions, :singleton_method_added
        alias_method :singleton_method_added, :singleton_method_added_with_method_definitions
      end
    end
  end
  
  module MethodAdditions
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :attr_accessor, :source, :name
    end
    
    module InstanceMethods
      def backtrace
        definition
      end
      
      def site
        backtrace.find { |x| x !~ /method_added/ } || "filtered:filtered"
      end
      
      def file
        @file ||= site.split(':')[0]
      end
      
      def line
        @line ||= site.split(':')[1]
      end
      
      def from
        definition
        @from
      end
    end
  end
  
  module ObjectAdditions
    def self.included(base)
      base.send :include, InstanceMethods
      
      base.send :alias_method, :method_without_method_definitions, :method
      base.send :alias_method, :method, :method_with_method_definitions
    end
    
    module InstanceMethods
      def method_with_method_definitions(name)
        result = method_without_method_definitions(name)
        result.source = self
        result.name = name
        result
      end
    end
  end
  
  module ClassAdditions
    def self.included(base)
      base.send :include, InstanceMethods

      base.send :alias_method, :instance_method_without_method_definitions, :instance_method
      base.send :alias_method, :instance_method, :instance_method_with_method_definitions
    end
    
    module InstanceMethods
      def instance_method_with_method_definitions(name)
        result = instance_method_without_method_definitions(name)
        result.source = self
        result.name = name
        result
      end
    end
  end
end

class Method
  include MethodTrace::MethodAdditions
  
  def definition
    @definition ||= begin
      if source.is_a?(Class)
        # if class: base class singleton methods
        source.superclasses.each do |cls|
          d = MethodTrace::MethodDefinition.definition_sites["#{cls.object_id}::#{self.name}"]
          @from = cls and return d if d
        end
      else
        # singleton methods
        d = MethodTrace::MethodDefinition.definition_sites["#{source.object_id}::#{self.name}"]
        @from = 'singleton' and return d if d
      end
      
      # base class methods
      source.class.superclasses.each do |cls|
        d = MethodTrace::MethodDefinition.definition_sites["#{cls.object_id}##{self.name}"]
        @from = cls and return d if d
      end
      
      # module methods
      source.reachable_modules.each do |mod|
        d = MethodTrace::MethodDefinition.definition_sites["#{mod.object_id}##{self.name}"]
        @from = mod and return d if d
      end

      ['unknown']
    end
  end
end

class UnboundMethod
  include MethodTrace::MethodAdditions

  def definition
    @definition ||= begin
      source.ancestors.each do |ancestor|
        d = MethodTrace::MethodDefinition.definition_sites["#{ancestor.object_id}##{self.name}"]
        @from = ancestor and return d if d
      end
      
      ['unknown']
    end
  end
end

class Module
  include MethodTrace::MethodDefinition
end

class Object
  extend MethodTrace::MethodDefinition
  include MethodTrace::SingletonMethodDefinition
end

class Object
  include MethodTrace::ObjectAdditions
end

class Class
  include MethodTrace::ClassAdditions
end
