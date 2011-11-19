class AASM::SupportingClasses::Event
  attr_reader :name, :success, :options

  def initialize(name, options = {}, &block)
    @name = name
    @transitions = []
    update(options, &block)
  end

  # a neutered version of fire - it doesn't actually fir the event, it just
  # executes the transition guards to determine if a transition is even
  # an option given current conditions.
  def may_fire?(obj, to_state=nil)
    transitions = @transitions.select { |t| t.from == obj.aasm_current_state }
    return false if transitions.size == 0
    
    result = false
    transitions.each do |transition|
      next if to_state and !Array(transition.to).include?(to_state)
      if transition.perform(obj)
        result = true
        break
      end
    end
    result
  end
  
  def fire(obj, to_state=nil, *args)
    transitions = @transitions.select { |t| t.from == obj.aasm_current_state }
    #raise AASM::InvalidTransition, "Event '#{name}' cannot transition from '#{obj.aasm_current_state}'" if transitions.size == 0
    return false if transitions.size == 0
    next_state = nil
    transitions.each do |transition|
      next if to_state and !Array(transition.to).include?(to_state)
      if transition.perform(obj, *args)
        next_state = to_state || Array(transition.to).first
        transition.execute(obj, *args)
        break
      end
    end
    next_state
  end

  def transitions_from_state?(state)
    @transitions.any? { |t| t.from == state }
  end

  def transitions_from_state(state)
    @transitions.select { |t| t.from == state }
  end

  def all_transitions
    @transitions
  end

  def call_action(action, record)
    action = @options[action]
    action.is_a?(Array) ?
            action.each {|a| _call_action(a, record)} :
            _call_action(action, record)
  end

  def ==(event)
    if event.is_a? Symbol
      name == event
    else
      name == event.name
    end
  end

  def update(options = {}, &block)
    if options.key?(:success) then
      @success = options[:success]
    end
    if options.key?(:error) then
      @error = options[:error]
    end
    if block then
      instance_eval(&block)
    end
    @options = options
    self
  end

  def execute_success_callback(obj, success = nil)
    callback = success || @success
    case(callback)
      when String, Symbol
        obj.send(callback)
      when Proc
        callback.call(obj)
      when Array
        callback.each{|meth|self.execute_success_callback(obj, meth)}
    end
  end

  def execute_error_callback(obj, error, error_callback=nil)
    callback = error_callback || @error
    raise error unless callback
    case(callback)
      when String, Symbol
        raise NoMethodError unless obj.respond_to?(callback.to_sym)
        obj.send(callback, error)
      when Proc
        callback.call(obj, error)
      when Array
        callback.each{|meth|self.execute_error_callback(obj, error, meth)}
    end
  end

  private

  def _call_action(action, record)
    case action
      when Symbol, String
        record.send(action)
      when Proc
        action.call(record)
    end
  end

  def transitions(trans_opts)
    Array(trans_opts[:from]).each do |s|
      @transitions << AASM::SupportingClasses::StateTransition.new(trans_opts.merge({:from => s.to_sym}))
    end
  end
end
