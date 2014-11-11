require 'classes/player.rb'
require 'classes/dealer.rb'
require 'classes/deck.rb'

# Static variables:
STARTING_FUNDS = 1000
MINIMUM_BET = 5

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
  clear_screen
  num_players = 0
  valid = false
  until valid
    puts 'Number of players?'
    STDOUT.flush
    num_players = gets.chomp.to_i
    valid = valid_num_players(num_players)
  end
  players = []
  (1..num_players).each { players.push(Player.new(STARTING_FUNDS)) }
  dealer = Dealer.new

  while !players.empty?
    # Each player gets a turn to bet:
    players.each do |player|
      title = "#{player.name}'s turn."
      clear_and_title(title)

      player.new_game

      # Betting:
      bet = MINIMUM_BET
      valid = false
      until valid
        puts 'What do you want to bet?'
        STDOUT.flush
        bet = gets.chomp.to_i
        valid = valid_bet(bet, MINIMUM_BET)
      end

      # Deal:
      player.deal(deck.draw, deck.draw, bet)
    end
    dealer.new_game
    dealer.deal(deck.draw, deck.draw)

    # Each player gets a turn to play:
    players.each do |player|
      title = "#{player.name}'s turn."

      hands = player.hands

      # Player's turn:
      clear_and_title(title)
      puts "Dealer's hand: #{dealer.hand.display_hidden}"
      while hands.select{ |hand| !hand.finished? }.any?
        hands.select{ |hand| !hand.finished? }.each_with_index do |hand, i|
          # Player's action:

          continue = true
          while continue
            puts "#{player.name}'s hand ##{i + 1}: #{hand.display_all}\n\n"

            valid_actions = hand.valid_actions
            action = ''
            valid = false
            until valid
              puts "What action do you want to take? (#{valid_actions.join('/')})"
              STDOUT.flush
              action = gets.chomp
              valid = valid_action(action, valid_actions)
            end

            # Hit:
            if action == 'h'
              hand.hit(deck.draw)
            # Stand:
            elsif action == 'st'
              continue = false
              hand.stand
            # Double down:
            elsif action == 'dd'
              continue = false
              hand.double_down(deck.draw)
            # Split:
            elsif action == 'sp'
              continue = false
              hands.delete(hand)
              hands.concat(hand.split(deck.draw, deck.draw))
            end

            continue = (hand.alive? and continue)
          end

          if !hand.alive?
            puts "\nBusted!"
          end
          puts "This hand: #{hand.display_all}"

          pause
        end
      end
    end

    # Dealer's turn:
    while dealer.hand.total < 17
      dealer.hand.hit(deck.draw)
    end

    # Display scores:
    puts 'End of round! Here are the totals:'
    puts "Dealer:\t\t#{dealer.hand.display_all}"
    players.each do |player|
      hand = player.hands.map { |hand| hand.display_all }.join("\n\t\t")
      puts "#{player.name}:\t#{hand}"
    end
    pause
  end

  abort('Nobody else wants to play!')
end

# Check if input is a valid number of players:
def valid_num_players(num)
  if num == 0
    puts 'Invalid number.'
    return false
  elsif num > 10
    puts 'Too many players.'
    return false
  end
  true
end

# Check if bet is valid:
def valid_bet(num, minimum_bet)
  if num == 0
    puts 'Invalid number.'
    return false
  elsif num < minimum_bet
    puts "Bet must be higher than minimum (#{minimum_bet})."
    return false
  end
  true
end

def valid_action(action, valid_actions)
  if !valid_actions.include?(action)
    puts 'Invalid action.'
    return false
  end
  true
end

main()
