class Hand
  def initialize(card_visible, card_hidden)
    @cards = [card_visible, card_hidden]
  end

  def visible_card
    card = @cards.first
    if card == 1
      'A'
    elsif card == 11
      'J'
    elsif card == 12
      'Q'
    elsif card == 13
      'K'
    end
  end

  def hidden_cards_count
    @cards.length - 1
  end

  # Find the maximum total that attempts to stay under 21.
  def total
    sum = @cards.inject{ |sum, x| sum + [x, 10].min }
    aces = @cards.count(1)

    # Convert as many 1-value aces to 11-value aces as possible:
    while aces > 0 and sum + 10 <= 21
      sum += 10
      aces -= 1
    end

    sum
  end
end
