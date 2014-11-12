require 'classes/player.rb'
require 'classes/dealer.rb'
require 'classes/deck.rb'

# Static variables:
STARTING_FUNDS = 1000
MIN_BET = 5
MAX_PLAYERS = 9

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

# Main method. This gets run when the command 'ruby main.rb' is executed.:
def main
  deck = Deck.new

  # Ask for number of players:
  num_players = get_num_players

  # Create players and dealer:
  players = []
  (1..num_players).each { players.push(Player.new(STARTING_FUNDS)) }
  dealer = Dealer.new

  # While there are still players left, let's play a round.
  while active_players(players).any?
    deck.shuffle_if_needed

    # Each player gets a turn to bet:
    make_bets(players, deck)

    # A second check for active players after betting.
    if active_players(players).any?
      # Deal in the dealer; players already dealt:
      dealer.new_game
      dealer.deal(deck.draw, deck.draw)

      # If the dealer got blackjack, it's game over.
      if dealer.hand.blackjack?
        clear_screen
        puts 'Dealer got blackjack!'
        pause
      else
        # All players get a turn to play:
        take_actions(players, dealer, deck)
      end

      # Dealer's turn:
      dealer_turn(dealer, deck)

      # Calculate transactions:
      player_gains = calc_transactions(players, dealer)

      # Display scores:
      display_scores(players, dealer, player_gains)
    end
  end

  clear_screen
  abort('Everybody has cashed out. Looks like casino\'s done for tonight!')
end

# Return a list of all players who are still in the game:
def active_players(players)
  players.select{ |player| player.playing? }
end

# In one round, get bets from all players:
def make_bets(players, deck)
  active_players(players).each do |player|
    clear_and_title("#{player.name}'s turn to bet.")

    player.new_game

    # Automatically boot player if not enough funds.
    if !player.can_bet(MIN_BET)
      player.fold
      puts "You've been gambling too hard. You don't even have enough to play another round. We're going to mandate that you take the night off.\nSee you next time!"
    else
      bet = get_bet(player)
    end

    # If player hasn't folded, output his bet and deal his cards.
    if player.playing?
      puts "\nBetting base #{bet}."
      player.deal(deck.draw, deck.draw, bet)
    end

    pause
  end
end

# In one round, allow all players to take actions:
def take_actions(players, dealer, deck)
  active_players(players).each do |player|
    clear_and_title("#{player.name}'s turn to play.")

    puts "Dealer:\t\t\t#{dealer.hand.display_hidden}"
    player_turn(player, deck)
  end
end

# In one round, allow dealer to take default actions:
def dealer_turn(dealer, deck)
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
  clear_and_title('End of this round! Here\'s the summary.')
  puts "Dealer:\t\t#{dealer.hand.to_s}"
  active_players(players).each do |player|
    hand_strings = player.hands.map{ |hand| "#{hand.to_s}" }.join("\n\t\t")
    puts "#{player.name}:\t#{hand_strings}"
  end
  puts ''
  active_players(players).each do |player|
    puts "#{player.name} #{player_gains[player] < 0 ? 'lost' : 'gained'} #{player_gains[player].abs}.\tTotal funds: #{player.funds}."
  end

  delta = player_gains.values.inject(:+)
  if delta < 0
    puts "\nSeems that the casino cashed out this round!"
  end

  pause
end

# On one player's turn, allow him to take actions:
def player_turn(player, deck)
  hands = player.hands
  # Figure out what the player wants to do with each hand:
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
    return false
  end

  # If not bust or stand, player can keep going:
  continue = true
  while continue
    puts "#{player.name}'s hand ##{i + 1}:\t#{hand.to_s}\n\n"

    action = get_hand_action(hand)
    proceed = apply_action(action, hand, player.hands, deck)
    continue = (hand.alive? and proceed)
  end

  # If the action is a split, we have to redo everything:
  if action == 'sp'
    return true
  end

  if !hand.alive?
    puts "\nBusted!"
  end
  puts "\nFinal hand:\t\t#{hand.to_s}"

  pause
  true
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
    hand.split(deck.draw, deck.draw)
  end
  false
end

# Ask the user for the number of players:
def get_num_players
  clear_screen
  num_players = 0
  valid = false
  until valid
    puts 'How many of you want to play?'
    STDOUT.flush
    num_players = gets.chomp.to_i
    valid = valid_num_players(num_players, MAX_PLAYERS)
  end
  num_players
end

# Ask the player for his bet:
def get_bet(player)
  puts "You have #{player.funds}.\n"

  bet = MIN_BET
  valid = false
  until valid
    puts 'What do you want to bet? Bet 0 to quit.'
    STDOUT.flush
    bet = gets.chomp
    # Quitting action:
    if bet == '0'
      puts 'Bye!'
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
