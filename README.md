Ruby-Blackjack
==============

Command-line Blackjack in Ruby!

Supports Ruby 1.8.7 and up.

# Setup

## Install
* Use Rbenv to install.
* Refer to [this link](https://github.com/sstephenson/rbenv).
* To run the program, execute `ruby main.rb` from the root directory.

## Actions
* Each player must either bet `0` to quit or an amount equal to or greater than the ante.
* In play, a player can choose to hit, stand, double down, or split.
  * To hit, type `h`.
  * To stand, type `st`.
  * To double down, type `dd`.
  * To split, type `sp`.
  * Note that any actions that require extra funds in addition to the base bet are only available if the user has enough funds.
    * For example, if a user has 400 and bets 300, he cannot double down or split.

## Dependencies
* Nothing yet. Stay tuned!

# House Rules

## Betting
* Each player starts with 1000 unnamed currency.
* The ante is 5.
* Once a player loses funds below the ante, he is booted from the game.

## Side Rules
* On the first turn of a hand, a player can choose to double down or split.
  * These actions are only available if the player has enough funds to bet this much.
* A player can split as many times as splits appear.

## Blackjacks
* Blackjacks count for 1.5 times the amount bet. This applies to players only, not the dealer.
* If any of the players, including the dealer, gets a blackjack, the game stops.
  * Players with blackjacks get a "push," and their bet is returned.
  * Players without a blackjack lose their bet.
