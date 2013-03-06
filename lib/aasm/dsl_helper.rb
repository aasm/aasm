module DslHelper

  class Proxy
    attr_accessor :options

    def initialize(options, valid_keys, source)
      @valid_keys = valid_keys
      @source = source

      @options = options
    end

    def method_missing(name, *args, &block)
      if @valid_keys.include?(name)
        options[name] = Array(options[name])
        options[name] << block if block
        options[name] += Array(args)
      else
        @source.send name, *args, &block
      end
    end
  end

  def add_options_from_dsl(options, valid_keys, &block)
    proxy = Proxy.new(options, valid_keys, self)
    proxy.instance_eval(&block)
    proxy.options
  end

end