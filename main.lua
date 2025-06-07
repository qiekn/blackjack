function love.load()
  deck = {}
  for suitIndex, suit in ipairs({ "club", "diamond", "heart", "spade" }) do
    for rank = 1, 13 do
      table.insert(deck, { suit = suit, rank = rank })
      print("suit: " .. suit .. ", rank: " .. rank)
    end
  end

  print("total number of cards in deck: " .. #deck)

  playerHand = {}
  table.insert(playerHand, table.remove(deck, love.math.random(#deck)))
  table.insert(playerHand, table.remove(deck, love.math.random(#deck)))

  dealerHand = {}
  table.insert(dealerHand, table.remove(deck, love.math.random(#deck)))
  table.insert(dealerHand, table.remove(deck, love.math.random(#deck)))

  print("total number of cards in deck: " .. #deck)
end

function love.draw()
  local output = {}

  table.insert(output, "Player hand:")
  for cardIndex, card in ipairs(playerHand) do
    table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
  end

  table.insert(output, "")

  table.insert(output, "Dealer hand:")
  for cardIndex, card in ipairs(dealerHand) do
    table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
  end

  love.graphics.print(table.concat(output, "\n"), 15, 15)
end
