class WithEnumWithoutColumn < ActiveRecord::Base
  include AASM

  if ActiveRecord.gem_version >= Gem::Version.new('7') && ActiveRecord.gem_version < Gem::Version.new('8')
    enum status: {
      opened: 0,
      closed: 1
    }
  end

  aasm :column => :status do
    state :closed, initial: true
    state :opened

    event :view do
      transitions :to => :opened, :from => :closed
    end
  end
end

class MultipleWithEnumWithoutColumn < ActiveRecord::Base
  include AASM

  if ActiveRecord.gem_version >= Gem::Version.new('7') && ActiveRecord.gem_version < Gem::Version.new('8')
    enum status: {
      opened: 0,
      closed: 1
    }
  end

  aasm :left, :column => :status do
    state :closed, initial: true
    state :opened

    event :view do
      transitions :to => :opened, :from => :closed
    end
  end
end
