require 'classes/hand.rb'

class Dealer < Player
  def initialize
    @name = "Dealer"
  end

  def new_game
    @game_stats = {
      'hand' => nil,
    }
  end

  # Playing:
  def deal(card_visible, card_hidden)
    @game_stats['hand'] = Hand.new(card_visible, card_hidden, 0)
  end

  def hand
    @game_stats['hand']
  end
end
