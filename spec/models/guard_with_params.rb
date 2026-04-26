class GuardWithParams
  include AASM
  aasm do
    state :new, :reviewed, :finalized

    event :mark_as_reviewed do
      transitions :from => :new, :to => :reviewed, :guards => [:user_is_manager?]
    end
  end

  def user_is_manager?(user)
    ok = false
    if user && user.has_role?(:manager)
      ok = true
    end
    return ok
  end
end

class GuardParamsClass
  def has_role?(role)
    true
  end
end
