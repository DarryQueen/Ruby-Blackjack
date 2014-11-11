class Hand
  def initialize(card_visible, card_hidden, bet)
    @bet = bet
    @cards = [card_visible, card_hidden]

    @finished = false
    @busted = false
  end

  def any?
    return @cards.any?
  end

  def finished?
    @finished
  end

  def display_hidden
    display = self.class.card_display(@cards.first)
    (1..@cards.count-1).each { display += ' *' }
    return display.strip
  end

  def display_all
    display = ''
    @cards.each do |card|
      display += self.class.card_display(card) + ' '
    end
    return display.strip
  end

  def valid_actions
    actions = ['h', 'st']
    if @cards.count == 2
      actions.push('dd')
      if self.class.card_value(@cards.first) == self.class.card_value(@cards.last)
        actions.push('sp')
      end
    end
    actions
  end

  def alive?
    if total > 21
      @finished = true
      @bust = true
      return false
    end
    true
  end

  def hit(card)
    @cards.push(card)
  end

  def stand
    @finished = true
  end

  def double_down(card)
    @bet *= 2
    @cards.push(card)
    @finished = true
  end

  def split(card1, card2)
    [Hand.new(@cards.first, card1, @bet), Hand.new(@cards.last, card2, @bet)]
  end

  # Find the maximum total that attempts to stay under 21.
  def total
    sum = @cards.inject{ |sum, x| sum + self.class.card_value(x) }
    aces = @cards.count(1)

    # Convert as many 1-value aces to 11-value aces as possible:
    while aces > 0 and sum + 10 <= 21
      sum += 10
      aces -= 1
    end

    sum
  end

  # Private static methods:
  private

  def self.card_display(card)
    if card == 1
      return 'A'
    elsif card == 11
      return 'J'
    elsif card == 12
      return 'Q'
    elsif card == 13
      return 'K'
    end
    return card.to_s
  end

  def self.card_value(card)
    return [card, 10].min
  end
end
