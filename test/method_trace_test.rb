require "test/unit"
require "rubygems"
require "mocha"

require File.dirname(__FILE__) + '/../lib/method_trace'

class MethodTraceTest < Test::Unit::TestCase
  module TestModule
    def some_module_method
    end
    
    def self.some_module_singleton_method
    end
  end
  
  class TestClass
    def some_instance_method
    end
    
    def self.some_singleton_method
    end
  end
  
  class SecondTestClass
    include TestModule
  end
  
  class ThirdTestClass
    extend TestModule
  end
  
  class FourthTestClass < TestClass
    def some_subclass_method
    end
    
    def self.some_subclass_singleton_method
    end
  end
  
  def setup
  end
  
  def test_should_trace_class_method_definition
    o = TestClass.new
    m = o.method(:some_instance_method)
    assert_found m, TestClass
  end
  
  def test_should_trace_class_instance_method_definition
    m = TestClass.instance_method(:some_instance_method)
    assert_found m, TestClass
  end
  
  def test_should_trace_class_singleton_method_definition
    m = TestClass.method(:some_singleton_method)
    assert_found m, TestClass
  end
  
  def test_should_trace_object_singleton_method_definition
    o = TestClass.new
    def o.some_object_singleton_method
    end
    
    m = o.method(:some_object_singleton_method)
    assert_found m, 'singleton'
  end
  
  def test_should_trace_module_singleton_method_definition
    m = TestModule.method(:some_module_singleton_method)
    assert_found m, 'singleton'
  end
  
  def test_should_trace_class_method_definition_through_include
    o = SecondTestClass.new
    m = o.method(:some_module_method)
    assert_found m, TestModule
  end
  
  def test_should_trace_class_instance_method_definition_through_include
    m = SecondTestClass.instance_method(:some_module_method)
    assert_found m, TestModule
  end
  
  def test_should_trace_class_singleton_definition_through_extend
    m = ThirdTestClass.method(:some_module_method)
    assert_found m, TestModule
  end
  
  def test_should_trace_object_singleton_definition_through_extend
    o = TestClass.new
    o.extend(TestModule)
    
    m = o.method(:some_module_method)
    assert_found m, TestModule
  end
  
  def test_should_trace_superclass_method_definition
    o = FourthTestClass.new
    m = o.method(:some_instance_method)
    assert_found m, TestClass
  end
  
  def test_should_trace_superclass_instance_method_definition
    m = FourthTestClass.instance_method(:some_instance_method)
    assert_found m, TestClass
  end
  
  def test_should_trace_superclass_singleton_method_definition
    m = FourthTestClass.method(:some_singleton_method)
    assert_found m, TestClass
  end

protected
  def assert_found(method, from)
    assert method.file != nil && method.file != 'unknown'
    assert_not_nil method.line
    assert_not_nil method.backtrace
    assert_equal from, method.from
  end
end
