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

  def funds
    @funds
  end

  def new_game
    @game_stats = {
      'hands' => [],
      'bet' => 0,
    }
  end

  # Playing:
  def deal(card_visible, card_hidden, bet)
    @game_stats['hands'].push(Hand.new(card_visible, card_hidden, bet, self))
    @game_stats['bet'] = bet
  end

  def hands
    @game_stats['hands']
  end

  def compare_hands(dealer_hand)
    delta = 0
    dealer_bust = !dealer_hand.alive?
    @game_stats['hands'].each do |hand|
      if hand.alive? and (dealer_bust or hand.total > dealer_hand.total)
        delta += hand.bet
      else
        delta -= hand.bet
      end
    end
    @funds += delta
    delta
  end
end
