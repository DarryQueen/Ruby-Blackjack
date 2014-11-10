class Deck
  def initialize
    @cards = Array.new(13, 4)
  end

  # Randomly select from the current deck.
  def draw
    card_position = rand(@cards.inject(:+))
    card = 0
    while card_position >= 0
      card_position -= @cards[card]
      card += 1
    end
    @cards[card - 1] -= 1
    card
  end

  def reset
    @cards = Array.new(13, 4)
  end
end
