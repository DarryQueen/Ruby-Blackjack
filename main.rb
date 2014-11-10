require 'classes/player.rb'
require 'classes/deck.rb'

def valid_num(num)
  if num == 0
    puts 'Invalid number.'
    return false
  elsif num > 10
    puts 'Too many players.'
    return false
  end
  true
end

deck = Deck.new

# Ask for number of players:
num_players = 0
valid = false
until valid
  puts 'Number of players?'
  STDOUT.flush
  num_players = gets.chomp.to_i
  valid = valid_num(num_players)
end
players = Array.new(num_players, Player.new(1000))

# Iterate per game:
