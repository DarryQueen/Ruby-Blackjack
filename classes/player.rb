require 'classes/hand.rb'

class Player
  @@player_count = 0

  def initialize(starting_funds)
    @name = "Player#{@@player_count}"
    @funds = starting_funds
    @@player_count += 1
  end

  def name
    @name
  end

  def new_game
    @game_stats = {
      'hands' => [],
      'bet' => 0,
    }
  end

  # Playing:
  def deal(card_visible, card_hidden, bet)
    @game_stats['hands'].push(Hand.new(card_visible, card_hidden, bet))
    @game_stats['bet'] = bet
  end

  def hands
    @game_stats['hands']
  end
end
