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

  while !players.select{ |player| player.playing? }.empty?
    deck.shuffle_if_needed

    # Each player gets a turn to bet:
    players.select{ |player| player.playing? }.each do |player|
      title = "#{player.name}'s turn."
      clear_and_title(title)

      player.new_game

      # Betting:
      bet = MINIMUM_BET
      valid = false
      until valid
        puts "What do you want to bet? You have #{player.funds}. 0 to exit."
        STDOUT.flush
        bet = gets.chomp
        # Quitting action:
        if bet == '0'
          valid = true
          puts 'Bye! Come back later!'
          player.fold
          next
        end
        bet = bet.to_i
        valid = valid_bet(bet, MINIMUM_BET, player)
      end

      if player.playing?
        puts "\nBetting #{bet}."
        player.deal(deck.draw, deck.draw, bet)
      end

      pause
    end

    dealer.new_game
    dealer.deal(deck.draw, deck.draw)

    if dealer.hand.blackjack?
      clear_screen
      puts 'Dealer got blackjack!'
      pause
    else
      # Each player gets a turn to play:
      players.select{ |player| player.playing? }.each do |player|
        title = "#{player.name}'s turn."

        hands = player.hands

        # Player's turn:
        clear_and_title(title)
        puts "Dealer's hand: #{dealer.hand.display_hidden}"
        while hands.select{ |hand| !hand.finished? }.any?
          hands.select{ |hand| !hand.finished? }.each_with_index do |hand, i|
            # Player's action:
            continue = true

            # Blackjack!
            if hand.blackjack?
              puts 'Blackjack!'
              continue = false
            end

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
            puts "\nFinal hand: #{hand.display_all}"

            pause
          end
        end
      end
    end

    # Dealer's turn:
    while dealer.hand.total < 17
      dealer.hand.hit(deck.draw)
    end

    # Calculate transactions:
    player_gains = {}
    players.select{ |player| player.playing? }.each do |player|
      player_gains[player] = player.compare_hands(dealer.hand)
    end

    # Display scores:
    clear_and_title('End of round! Here are the totals:')
    puts "Dealer:\t\t#{dealer.hand.display_all} (#{dealer.hand.display_or_busted})"
    players.select{ |player| player.playing? }.each do |player|
      hand_strings = player.hands.map{ |hand| "#{hand.display_all} (#{hand.display_or_busted})" }.join("\n\t\t")
      puts "#{player.name}:\t#{hand_strings}"
    end
    puts ''
    players.select{ |player| player.playing? }.each do |player|
      puts "#{player.name} #{player_gains[player] < 0 ? 'forfeit' : 'gained'} #{player_gains[player].abs}.\tTotal funds: #{player.funds}."
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
def valid_bet(num, minimum_bet, player)
  if num == 0
    puts 'Invalid number.'
    return false
  elsif num < minimum_bet
    puts "Bet must be higher than minimum (#{minimum_bet})."
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
