class Hand
  def initialize(card_visible, card_hidden, bet, player)
    @owner = player
    @bet = bet
    @cards = [card_visible, card_hidden]

    @finished = false
    @busted = false
  end

  def bet
    @bet
  end

  def finished?
    @finished
  end

  # Display methods:
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

  def display_or_busted
    alive? ? (blackjack? ? 'Blackjack!' : total) : 'Busted'
  end

  def to_s
    "#{display_all} (#{display_or_busted})"
  end

  # Playing:
  def blackjack?
    blackjack = (@cards.count == 2 and total == 21)
    @finished = blackjack ? true : @finished
    blackjack
  end

  def valid_actions
    actions = ['h', 'st']
    if @cards.count == 2 and @owner.can_bet(@bet)
      actions.push('dd')
      if self.class.card_value(@cards.first) == self.class.card_value(@cards.last)
        actions.push('sp')
      end
    end
    actions
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
    hands = @owner.hands
    hands.delete(self)
    hands.push(Hand.new(@cards.first, card1, @bet, @owner), Hand.new(@cards.last, card2, @bet, @owner))
  end

  def alive?
    if total > 21
      @finished = true
      @bust = true
      return false
    end
    true
  end

  # Find the maximum total that attempts to stay under 21.
  def total
    sum = 0
    @cards.each { |card| sum += self.class.card_value(card) }
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

  # Get the string display of the card.
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
    card.to_s
  end

  # Get the numerical value of the card.
  def self.card_value(card)
    [card, 10].min
  end
end
