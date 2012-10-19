module AASM
  module SupportingClasses
    class Event
      attr_reader :name, :success, :options

      def initialize(name, options = {}, &block)
        @name = name
        @transitions = []
        update(options, &block)
      end

      # a neutered version of fire - it doesn't actually fire the event, it just
      # executes the transition guards to determine if a transition is even
      # an option given current conditions.
      def may_fire?(obj, to_state=nil, *args)
        _fire(obj, true, to_state, *args) # true indicates test firing
      end
  
      def fire(obj, to_state=nil, *args)
        _fire(obj, false, to_state, *args) # false indicates this is not a test (fire!)
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

      def fire_callbacks(action, record)
        action = @options[action]
        action.is_a?(Array) ?
                action.each {|a| _fire_callbacks(a, record)} :
                _fire_callbacks(action, record)
      end

      def ==(event)
        if event.is_a? Symbol
          name == event
        else
          name == event.name
        end
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

      # Execute if test? == false, otherwise return true/false depending on whether it would fire
      def _fire(obj, test, to_state=nil, *args)
        if @transitions.map(&:from).any?
          transitions = @transitions.select { |t| t.from == obj.aasm_current_state }
          return nil if transitions.size == 0
        else
          transitions = @transitions
        end

        result = test ? false : nil
        transitions.each do |transition|
          next if to_state and !Array(transition.to).include?(to_state)
          if transition.perform(obj, *args)
            if test
              result = true
            else
              result = to_state || Array(transition.to).first
              transition.execute(obj, *args)
            end

            break
          end
        end
        result
      end

      def _fire_callbacks(action, record)
        case action
          when Symbol, String
            record.send(action)
          when Proc
            action.call(record)
        end
      end

      def transitions(trans_opts)
        # Create a separate transition for each from state to the given state
        Array(trans_opts[:from]).each do |s|
          @transitions << AASM::SupportingClasses::StateTransition.new(trans_opts.merge({:from => s.to_sym}))
        end
        # Create a transition if to is specified without from (transitions from ANY state)
        @transitions << AASM::SupportingClasses::StateTransition.new(trans_opts) if @transitions.empty? && trans_opts[:to]
      end

    end
  end # SupportingClasses
end # AASM
