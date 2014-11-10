require 'classes/hand.rb'

class Player
  def initialize(starting_funds)
    @funds = starting_funds
  end

  def is_active
    @hand.any?
  end

  def deal(card_visible, card_hidden)
    @hand = Hand.new(card_visible, card_hidden)
  end

  def hand
    @hand
  end
end
