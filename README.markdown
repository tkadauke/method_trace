# method_trace

This gem adds a couple of useful methods to the various Method classes in Ruby which allow you to find the definition site of a method. It is intended for debugging, not for production use. It is mainly useful in Matz Ruby 1.8, since Ruby 1.9 as well as Rubinius have similar features built in.

## the problem

You call a method and it behaves weird. You try to debug it by adding some debug output, only to realize that your method is not even called! Some other part of your application (or some external library) must have silently overwritten your method and now you don't know which version of your method is called and when it was overwritten and why.

## the solution

method_trace to the rescue! Simply require method_trace before everything else and start your application. When it is time to figure out where your method was defined, use one of the introspection methods provided by method_trace.

## examples

Find the backtrace of the definition of an instance method:

    String.instance_method(:singularize).backtrace

Find the file in which a method is defined:

    "hello world".method(:pluralize).file

Find the line in which a singleton method is defined:

    x = "foo"
    def x.bar
    end

    x.method(:bar).line

Find the module/class in which a method was defined:

    "ships".method(:classify).from

## limitations

1. The introspection does only work for methods that were defined after method_trace was required
2. The introspection does not work for native methods written in C
