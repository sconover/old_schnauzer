class Object
  def singleton_class
    (class << self; self; end)
  end
end

class Decorator
  def before(&block)
    @before = block
  end
  
  def after(&block)
    @after = block
  end
  
  def apply_to(subject)
    before_block = @before
    after_block = @after
    
    subject.public_methods(false).each do |method|
      next if method == "inspect"
      subject.singleton_class.class_eval do
        original_method_symbol = "original_#{method}".to_sym
        alias_method original_method_symbol, method
        
        define_method(method) do |*args|
          before_block.call(method.to_sym, args) if before_block
          
          result = subject.send(original_method_symbol, *args)
          
          after_block.call(method.to_sym, args, result) if after_block
          
          result
        end
      end
    end
  end
end