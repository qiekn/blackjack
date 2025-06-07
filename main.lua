function love.load()
  roundOver = false
  deck = {}
  for suitIndex, suit in ipairs({ "club", "diamond", "heart", "spade" }) do
    for rank = 1, 13 do
      table.insert(deck, { suit = suit, rank = rank })
      print("suit: " .. suit .. ", rank: " .. rank)
    end
  end

  function takeCard(hand)
    table.insert(hand, table.remove(deck, love.math.random(#deck)))
  end

  playerHand = {}
  takeCard(playerHand)
  takeCard(playerHand)

  dealerHand = {}
  takeCard(dealerHand)
  takeCard(dealerHand)

  print("total number of cards in deck: " .. #deck)
end

function love.draw()
  local function getTotal(hand)
    local total = 0
    local hasAce = false
    for cardIndex, card in ipairs(hand) do
      if card.rank > 10 then
        total = total + 10
      else
        total = total + card.rank
      end

      if card.rank == 1 then
        hasAce = true
      end
    end

    if hasAce and total <= 11 then
      total = total + 10
    end
    return total
  end

  local output = {}

  table.insert(output, "Player hand:")
  for cardIndex, card in ipairs(playerHand) do
    table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
  end
  table.insert(output, "Total: " .. getTotal(playerHand))

  table.insert(output, "")

  table.insert(output, "Dealer hand:")
  for cardIndex, card in ipairs(dealerHand) do
    table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
  end
  table.insert(output, "Total: " .. getTotal(dealerHand))

  -- Draw the winner
  if roundOver then
    table.insert(output, "")

    local function hasHandWon(thisHand, otherHand)
      return getTotal(thisHand) <= 21
        and (
          getTotal(otherHand) > 21
          or getTotal(thisHand) > getTotal(otherHand)
        )
    end

    if hasHandWon(playerHand, dealerHand) then
      table.insert(output, "Player wins")
    elseif hasHandWon(dealerHand, playerHand) then
      table.insert(output, "Dealer wins")
    else
      table.insert(output, "Draw")
    end
  end

  -- Print output
  love.graphics.print(table.concat(output, "\n"), 15, 15)
end

function love.keypressed(key)
  if not roundOver then
    if key == "h" then -- Take card
      takeCard(playerHand)
    elseif key == "s" then -- Stands
      roundOver = true
    end
  else
    love.load() -- Play again
  end
end
