class Deck
  @@SHUFFLE_AT = 50

  def initialize
    @cards = Array.new(13, 4)
  end

  # Randomly select from the current deck.
  def draw
    card_count = @cards.inject(:+)

    card_position = rand(card_count)
    card = 0
    while card_position >= 0
      card_position -= @cards[card]
      card += 1
    end
    @cards[card - 1] -= 1
    card
  end

  # Determine if we need to reset the deck.
  def shuffle_if_needed
    card_count = @cards.inject(:+)
    if card_count <= @@SHUFFLE_AT
      reset
    end
  end

  def reset
    @cards = Array.new(13, 4)
  end
end
