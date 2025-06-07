# Blackjack

This project is an exercise for this tutorial.

[A tutorial for Lua and LÖVE 11](https://berbasoft.com/simplegametutorials/love/blackjack/)

## Rules

The dealer and player are dealt two cards each. The dealer's first card is hidden from the player.

The player can hit (i.e. take another card) or stand (i.e. stop taking cards).

If the total value of the player's hand goes over 21, then they have gone bust.

Face cards (king, queen and jack) have a value of 10, and aces have a value of 11 unless this would make the total value of the hand go above 21, in which case they have a value of 1.

After the player has stood or gone bust, the dealer takes cards until the total of their hand is 17 or over.

The round is then over, and the hand with the highest total (if the total is 21 or under) wins the round.
