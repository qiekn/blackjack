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

  print("Player Hand")
  for cardIndex, card in ipairs(playerHand) do
    print("suit: " .. card.suit .. ", rank: " .. card.rank)
  end

  print("total number of cards in deck: " .. #deck)
end

function love.draw()
  local output = {}

  table.insert(output, "Player Hand:")
  for cardIndex, card in ipairs(playerHand) do
    table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
  end

  love.graphics.print(table.concat(output, "\n"), 15, 15)
end
