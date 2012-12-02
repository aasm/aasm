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
      transitions :from => :sleeping, :to => :working, :on_transition => :wear_clothes
      transitions :from => :showering, :to => [:working, :dating], :on_transition => Proc.new { |obj, *args| obj.wear_clothes(*args) }
      transitions :from => :showering, :to => :prettying_up, :on_transition => [:condition_hair, :fix_hair]
    end
  end

  def wear_clothes(shirt_color, trouser_type)
  end

  def condition_hair
  end

  def fix_hair
  end
end
