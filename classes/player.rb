require 'classes/hand.rb'

class Player
  @@player_count = 0

  def initialize(starting_funds)
    @@player_count += 1

    @name = "Player #{@@player_count}"
    @funds = starting_funds
    @playing = true
  end

  def name
    @name
  end

  def playing?
    @playing
  end

  def turn_over?
    @game_stats['turn_over']
  end

  def funds
    @funds
  end

  def profited?(starting_funds)
    if funds > starting_funds
      return true
    end
    false
  end

  # Reset game stats. 'bet' attribute may not be needed. Fold if out of funds:
  def new_game(min_bet)
    # Automatically boot player if not enough funds.
    @game_stats = {
      'hands' => [],
      'active_hand' => nil,
      'turn_over' => false,
      'bet' => 0,
    }
    if !can_bet(min_bet)
      fold
      return
    end
  end

  # Playing:
  def active_hand
    @game_stats['active_hand'].to_s
  end

  def hands_strings
    @game_stats['hands'].map{ |hand| "#{hand.to_s}" }
  end

  def blackjack?
    @game_stats['active_hand'].blackjack?
  end

  def valid_actions
    @game_stats['active_hand'].valid_actions
  end

  # Perform a turn:
  def turn(action, deck)
    result = ''

    hand = @game_stats['active_hand']
    # Hit:
    if action == 'h'
      hand.hit(deck.draw)
      result = hand.alive? ? 'proceed' : 'busted'
    # Stand:
    elsif action == 'st'
      hand.stand
      result = 'done'
    # Double down:
    elsif action == 'dd'
      hand.double_down(deck.draw)
      result = hand.alive? ? 'done' : 'busted'
    # Split:
    elsif action == 'sp'
      hand.split(deck.draw, deck.draw)
      result = 'split'
    end
    return result
  end

  def update_turn
    hands = @game_stats['hands'].select{ |hand| !hand.finished? }
    if hands.any?
      @game_stats['active_hand'] = hands.first
    else
      @game_stats['turn_over'] = true
    end
  end

  def deal(card_visible, card_hidden, bet)
    if can_bet(bet)
      @game_stats['hands'].push(Hand.new(card_visible, card_hidden, bet, self))
      @game_stats['active_hand'] = @game_stats['hands'].first
      @game_stats['bet'] = bet
    end
  end

  # Main method should not use this method:
  def hands
    @game_stats['hands']
  end

  def fold
    @playing = false
  end

  def can_bet(bet)
    bet <= @funds - @game_stats['hands'].map{ |hand| hand.bet }.inject(:+).to_i
  end

  def compare_hands(dealer)
    dealer_hand = dealer.hand
    delta = 0
    dealer_bust = !dealer_hand.alive?
    dealer_blackjack = dealer_hand.blackjack?
    @game_stats['hands'].each do |hand|
      if dealer_blackjack
        delta -= hand.blackjack? ? 0 : hand.bet
      elsif hand.blackjack?
        # Extra reward for blackjack:
        delta += (1.5 * hand.bet).to_i
      elsif hand.alive?
        # Dealer is busted or hand is better:
        if (dealer_bust or hand.total > dealer_hand.total)
          delta += hand.bet
        # Hand is worse:
        elsif hand.total < dealer_hand.total
          delta -= hand.bet
        end
      # Player busted:
      else
        delta -= hand.bet
      end
    end
    @funds += delta
    delta
  end
end
