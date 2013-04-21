class ThisNameBetterNotBeInUse
  include AASM

  aasm do
    state :initial
    state :symbol
    state :string
    state :array
    state :proc
  end
end
