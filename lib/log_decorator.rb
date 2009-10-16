require "lib/decorator"

class LogDecorator
  def initialize(stream)
    @stream = stream
  end
  
  def apply_to(subject)
    the_stream = @stream
    
    decorator = Decorator.new
    decorator.before do |method_symbol, args|
      the_stream << "-> #{subject.class}.#{method_symbol.to_s}#{_args_to_s(args)}\n"
    end
    decorator.after do |method_symbol, args, result|
      the_stream << "<- #{subject.class}.#{method_symbol.to_s}#{_args_to_s(args)} : #{result.inspect}\n"
    end
    
    decorator.apply_to(subject)
  end
  
  def _args_to_s(args)
    if args.length > 0
      "(" + args.collect{|arg|arg.class.to_s}.join(", ") + ")"
    else
      ""
    end
  end
end