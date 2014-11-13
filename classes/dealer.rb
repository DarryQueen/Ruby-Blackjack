require 'classes/hand.rb'

class Dealer < Player
  def initialize
    @name = "Dealer"
  end

  def new_game
    @game_stats = {
      'hand' => nil,
      'turn_over' => false,
    }
  end
  
  # Display:
  def display_hidden
    @game_stats['hand'].display_hidden
  end

  def hands_strings
    [@game_stats['hand']]
  end

  # Playing:
  def turn(deck)
    hand = @game_stats['hand']
    if hand.total < 17
      hand.hit(deck.draw)
    end
  end

  def update_turn
    if hand.total >= 17
      @game_stats['turn_over'] = true
    end
  end

  def deal(card_visible, card_hidden)
    @game_stats['hand'] = Hand.new(card_visible, card_hidden, 0, self)
  end

  def hand
    @game_stats['hand']
  end
end
