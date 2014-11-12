require 'classes/player.rb'
require 'classes/dealer.rb'
require 'classes/deck.rb'

# Static variables:
STARTING_FUNDS = 1000
MIN_BET = 5
MAX_PLAYERS = 10

# Clear the screen:
def clear_screen
  system 'clear' or system 'cls'
end
def clear_and_title(heading)
  clear_screen
  puts "#{heading}\n\n"
end

# Pause for user input:
def pause
  puts "\nPress enter to continue."
  gets
end

# Main method:
def main
  deck = Deck.new

  # Ask for number of players:
  num_players = get_num_players
  players = []

  # Create players and dealer:
  (1..num_players).each { players.push(Player.new(STARTING_FUNDS)) }
  dealer = Dealer.new

  # While there are still players left, let's go through a round.
  while active_players(players).any?
    deck.shuffle_if_needed

    # Each player gets a turn to bet:
    make_bets(players, deck)

    if active_players(players).any?
      # Deal in the dealer:
      dealer.new_game
      dealer.deal(deck.draw, deck.draw)

      if dealer.hand.blackjack?
        clear_screen
        puts 'Dealer got blackjack!'
        pause
      else
        # Each player gets a turn to play:
        player_actions(players, dealer, deck)
      end

      # Dealer's turn:
      dealer_actions(dealer, deck)

      # Calculate transactions:
      player_gains = calc_transactions(players, dealer)

      # Display scores:
      display_scores(players, dealer, player_gains)
    end
  end

  clear_screen
  abort('Nobody else wants to play!')
end

# Return a list of all players who are still in the game:
def active_players(players)
  players.select{ |player| player.playing? }
end

# In one round, get bets from all players:
def make_bets(players, deck)
  active_players(players).each do |player|
    clear_and_title("#{player.name}'s turn.")

    player.new_game

    # Automatically boot player if bankrupt.
    if !player.can_bet(MIN_BET)
      player.fold
      puts "Looks like you've been gambling too hard. We're going to mandate that you take the night off.\nSee you next time!"
    else
      bet = get_bet(player)
    end

    if player.playing?
      puts "\nBetting #{bet}."
      player.deal(deck.draw, deck.draw, bet)
    end

    pause
  end
end

# In one round, allow all players to take actions:
def player_actions(players, dealer, deck)
  active_players(players).each do |player|
    clear_and_title("#{player.name}'s turn.")

    puts "Dealer's hand: #{dealer.hand.display_hidden}"
    hands_actions(player, deck)
  end
end

# In one round, allow dealer to take default actions:
def dealer_actions(dealer, deck)
  while dealer.hand.total < 17
    dealer.hand.hit(deck.draw)
  end
end

# Calculate the transactions:
def calc_transactions(players, dealer)
  player_gains = {}
  active_players(players).each do |player|
    player_gains[player] = player.compare_hands(dealer.hand)
  end
  player_gains
end

# Display the scoreboard:
def display_scores(players, dealer, player_gains)
  clear_and_title('End of round! Here are the totals:')
  puts "Dealer:\t\t#{dealer.hand.to_s}"
  active_players(players).each do |player|
    hand_strings = player.hands.map{ |hand| "#{hand.to_s}" }.join("\n\t\t")
    puts "#{player.name}:\t#{hand_strings}"
  end
  puts ''
  active_players(players).each do |player|
    puts "#{player.name} #{player_gains[player] < 0 ? 'forfeit' : 'gained'} #{player_gains[player].abs}.\tTotal funds: #{player.funds}."
  end
  pause
end

# On one player's turn, allow him to take actions:
def hands_actions(player, deck)
  hands = player.hands
  while hands.select{ |hand| !hand.finished? }.any?
    hands.select{ |hand| !hand.finished? }.each_with_index do |hand, i|
      hand_actions(player, hand, deck, i)
    end
  end
end

# On one player's hand, allow him to take actions:
def hand_actions(player, hand, deck, i)
  # Blackjack!
  if hand.blackjack?
    puts "#{player.name} got blackjack!"

    pause
    return
  end

  # Player's action:
  continue = true
  while continue
    puts "#{player.name}'s hand ##{i + 1}: #{hand.to_s}\n\n"

    action = get_hand_action(hand)
    proceed = apply_action(action, hand, player.hands, deck)
    continue = (hand.alive? and proceed)
  end

  if !hand.alive?
    puts "\nBusted!"
  end
  puts "\nFinal hand: #{hand.to_s}"

  pause
end

# Perform the given action:
def apply_action(action, hand, hands, deck)
  # Hit:
  if action == 'h'
    hand.hit(deck.draw)
    return true
  # Stand:
  elsif action == 'st'
    hand.stand
  # Double down:
  elsif action == 'dd'
    hand.double_down(deck.draw)
  # Split:
  elsif action == 'sp'
    hands.delete(hand)
    hands.concat(hand.split(deck.draw, deck.draw))
  end
  false
end

# Ask the user for the number of players:
def get_num_players
  clear_screen
  num_players = 0
  valid = false
  until valid
    puts 'Number of players?'
    STDOUT.flush
    num_players = gets.chomp.to_i
    valid = valid_num_players(num_players, MAX_PLAYERS)
  end
  num_players
end

# Ask the player for his bet:
def get_bet(player)
  bet = MIN_BET
  valid = false
  until valid
    puts "What do you want to bet? You have #{player.funds}. 0 to exit."
    STDOUT.flush
    bet = gets.chomp
    # Quitting action:
    if bet == '0'
      puts 'Bye! Come back later!'
      player.fold
      return
    end

    # Validation:
    bet = bet.to_i
    valid = valid_bet(bet, MIN_BET, player)
  end
  bet
end

def get_hand_action(hand)
  valid_actions = hand.valid_actions
  action = ''
  valid = false
  until valid
    puts "What action do you want to take? (#{valid_actions.join('/')})"
    STDOUT.flush
    action = gets.chomp
    valid = valid_action(action, valid_actions)
  end
  action
end

# Check if input is a valid number of players:
def valid_num_players(num, max_players)
  if num == 0
    puts 'Invalid number.'
    return false
  elsif num > max_players
    puts "Cannot have more than the max number of players (#{max_players})."
    return false
  end
  true
end

# Check if bet is valid:
def valid_bet(num, min_bet, player)
  if num == 0
    puts 'Invalid number.'
    return false
  elsif num < min_bet
    puts "Bet must be higher than minimum (#{min_bet})."
    return false
  elsif !player.can_bet(num)
    puts "Nice try, betting money you don't have."
    return false
  end
  true
end

# Check if action is valid:
def valid_action(action, valid_actions)
  if !valid_actions.include?(action)
    puts 'Invalid action.'
    return false
  end
  true
end

main()
