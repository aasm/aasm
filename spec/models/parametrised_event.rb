class ParametrisedEvent
  include AASM
  aasm do
    state :sleeping, :initial => true
    state :showering
    state :working
    state :dating
    state :prettying_up

    event :wakeup do
      transitions :from => :sleeping, :to => [:showering, :working]
    end

    event :dress do
      transitions :from => :sleeping, :to => :working, :after => :wear_clothes, :success => :wear_makeup
      transitions :from => :showering, :to => [:working, :dating], :after => Proc.new { |*args| wear_clothes(*args) }, :success => proc { |*args| wear_makeup(*args) }
      transitions :from => :showering, :to => :prettying_up, :after => [:condition_hair, :fix_hair], :success => [:touch_up_hair]
    end
  end

  def wear_clothes(shirt_color, trouser_type=nil)
  end

  def wear_makeup(makeup, moisturizer)
  end

  def condition_hair
  end

  def fix_hair
  end

  def touch_up_hair
  end
end
