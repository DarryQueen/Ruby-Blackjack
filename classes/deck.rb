class Deck
  @@SHUFFLE_AT = 26

  def initialize
    reset
  end

  def draw
    @cards.pop
  end

  # Determine if we need to reset the deck.
  def shuffle_if_needed
    if @cards.count <= @@SHUFFLE_AT
      reset
    end
  end

  def reset
    # Create 4 by 13 cards and randomly sort.
    @cards = ([*1..13] * 4).sort_by{ rand }
  end
end
