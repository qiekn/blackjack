function love.load()
  roundOver = false

  love.graphics.setBackgroundColor(1, 1, 1)

  images = {}
  -- stylua: ignore
  for nameIndex, name in ipairs({
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
    "pip_heart", "pip_diamond", "pip_club", "pip_spade",
    "mini_heart", "mini_diamond", "mini_club", "mini_spade",
    "card", "card_face_down",
    "face_jack", "face_queen", "face_king",
  }) do
    images[name] = love.graphics.newImage("images/" .. name .. ".png")
  end

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

  function getTotal(hand)
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

  playerHand = {}
  takeCard(playerHand)
  takeCard(playerHand)

  dealerHand = {}
  takeCard(dealerHand)
  takeCard(dealerHand)

  print("total number of cards in deck: " .. #deck)
end

function love.draw()
  local output = {}

  table.insert(output, "Player hand:")
  for cardIndex, card in ipairs(playerHand) do
    table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
  end
  table.insert(output, "Total: " .. getTotal(playerHand))

  table.insert(output, "")

  table.insert(output, "Dealer hand:")
  for cardIndex, card in ipairs(dealerHand) do
    if not roundOver and cardIndex == 1 then
      -- Until the round is over, the dealer's first card (i.e. the first
      -- item of the dealer's hand table) is hidden.
      table.insert(output, "(card hidden)")
    else
      table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
    end
  end

  if roundOver then
    table.insert(output, "Total: " .. getTotal(dealerHand))
  else
    table.insert(output, "Total: ?")
  end

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

  -- Draw cards
  local function drawCard(card, x, y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(images.card, x, y)

    local cardWidth = 53
    local cardHeight = 73
    local numberOffsetX = 3
    local numberOffsetY = 4
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(images[card.rank], x + numberOffsetX, y + numberOffsetY)
    love.graphics.draw(
      images[card.rank],
      x + cardWidth - numberOffsetX,
      y + cardHeight - numberOffsetY,
      0,
      -1
    )
  end

  -- Test start
  local testHand1 = {
    { suit = "club", rank = 1 },
    { suit = "diamond", rank = 2 },
    { suit = "heart", rank = 3 },
    { suit = "spade", rank = 4 },
    { suit = "club", rank = 5 },
    { suit = "diamond", rank = 6 },
    { suit = "heart", rank = 7 },
  }

  for cardIndex, card in ipairs(testHand1) do
    drawCard(card, (cardIndex - 1) * 60, 0)
  end

  local testHand2 = {
    { suit = "spade", rank = 8 },
    { suit = "club", rank = 9 },
    { suit = "diamond", rank = 10 },
    { suit = "heart", rank = 11 },
    { suit = "spade", rank = 12 },
    { suit = "club", rank = 13 },
  }

  for cardIndex, card in ipairs(testHand2) do
    drawCard(card, (cardIndex - 1) * 60, 80)
  end
  -- Test end
end

function love.keypressed(key)
  if not roundOver then
    -- Player
    if key == "h" then -- Take card
      takeCard(playerHand)
      -- If the player has gone bust or the value of their hadn is already 21,
      -- the round is automatically over.
      if getTotal(playerHand) >= 21 then
        roundOver = true
      end
    elseif key == "s" then -- Stands
      roundOver = true
    end
    -- Dealer
    if roundOver then
      while getTotal(dealerHand) < 17 do
        takeCard(dealerHand)
      end
    end
  else
    love.load() -- Play again
  end
end
