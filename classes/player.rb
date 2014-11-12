require 'classes/hand.rb'

class Player
  @@player_count = 0

  def initialize(starting_funds)
    @name = "Player#{@@player_count}"
    @funds = starting_funds
    @playing = true

    @@player_count += 1
  end

  def name
    @name
  end

  def playing?
    @playing
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
    if can_bet(bet)
      @game_stats['hands'].push(Hand.new(card_visible, card_hidden, bet, self))
      @game_stats['bet'] = bet
    end
  end

  def fold
    @playing = false
  end

  def hands
    @game_stats['hands']
  end

  def can_bet(bet)
    bet <= @funds - @game_stats['hands'].map{ |hand| hand.bet }.inject(:+).to_i
  end

  def compare_hands(dealer_hand)
    delta = 0
    dealer_bust = !dealer_hand.alive?
    dealer_blackjack = dealer_hand.blackjack?
    @game_stats['hands'].each do |hand|
      if dealer_blackjack
        delta -= hand.blackjack? ? 0 : hand.bet
      elsif hand.blackjack?
        # Double reward for blackjack:
        delta += 2 * hand.bet
      elsif hand.alive? and (dealer_bust or hand.total > dealer_hand.total)
        delta += hand.bet
      else
        delta -= hand.bet
      end
    end
    @funds += delta
    delta
  end
end
