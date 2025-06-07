function love.load()
  roundOver = false

  love.graphics.setBackgroundColor(1, 1, 1)

  -- HiDPI detection and setup
  local dpiScale = love.window.getDPIScale()
  local useHiDPI = dpiScale > 1
  local spritePath = useHiDPI and "images/2x/" or "images/1x/"
  local spriteScale = useHiDPI and 0.5 or 1

  debugPath = spritePath

  -- Load spritesheet
  spst_decks = love.graphics.newImage(spritePath .. "deck_opt.png")
  spst_enhancers = love.graphics.newImage(spritePath .. "enhancers.png")

  -- Card dimensions in spritesheet (assuming standard layout)
  local cardWidth = 71
  local cardHeight = 95
  local sheetCols = 13 -- 13 ranks (2-10, J, Q, K, A)
  local sheetRows = 4 -- 4 suits

  -- Store dimensions for drawing
  CARD_WIDTH = cardWidth * dpiScale
  CARD_HEIGHT = cardHeight * dpiScale
  DPI_SCALE = dpiScale
  SPRITE_SCALE = spriteScale

  -- Create quads for each card
  cardQuads = {}
  local suits = { "hearts", "clubs", "diamonds", "spades" }
  for suitIndex = 1, sheetRows do
    local suit = suits[suitIndex]
    cardQuads[suit] = {}
    for rank = 1, sheetCols do
      local x = (rank - 1) * CARD_WIDTH
      local y = (suitIndex - 1) * CARD_HEIGHT
      cardQuads[suit][rank % 13 + 1] = love.graphics.newQuad(
        x,
        y,
        CARD_WIDTH,
        CARD_HEIGHT,
        spst_decks:getDimensions()
      )
    end
  end

  -- Card back quad
  -- stylua: ignore start
  cardBackQuad = love.graphics.newQuad(0, 0, CARD_WIDTH, CARD_HEIGHT, spst_enhancers:getDimensions())
  cardPlainQuad = love.graphics.newQuad(1 * CARD_WIDTH, 0, CARD_WIDTH, CARD_HEIGHT, spst_enhancers:getDimensions())
  -- stylua: ignore end

  -- Buttons
  local buttonY = 280
  local buttonHeight = 25
  local textOffsetY = 6

  buttonHit = {
    x = 10,
    y = buttonY,
    width = 53,
    height = buttonHeight,
    text = "Hit!",
    textOffsetX = 16,
    textOffsetY = textOffsetY,
  }

  buttonStand = {
    x = 70,
    y = buttonY,
    width = 53,
    height = buttonHeight,
    text = "Stand",
    textOffsetX = 8,
    textOffsetY = textOffsetY,
  }

  buttonPlayAgain = {
    x = 10,
    y = buttonY,
    width = 113,
    height = buttonHeight,
    text = "Play again",
    textOffsetX = 24,
    textOffsetY = textOffsetY,
  }

  ------------------------
  --  Global Functions  --
  ------------------------

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

  function isMouseInButton(button)
    return love.mouse.getX() >= button.x
      and love.mouse.getX() < button.x + button.width
      and love.mouse.getY() >= button.y
      and love.mouse.getY() < button.y + button.height
  end

  function reset()
    -- Deck
    deck = {}
    for suitIndex, suit in ipairs({ "clubs", "diamonds", "hearts", "spades" }) do
      for rank = 1, 13 do
        table.insert(
          deck,
          { suit = suit, rank = rank, quad = cardQuads[suit][rank] }
        )
      end
    end

    playerHand = {}
    takeCard(playerHand)
    takeCard(playerHand)

    dealerHand = {}
    takeCard(dealerHand)
    takeCard(dealerHand)

    roundOver = false
  end

  reset()
end

function love.draw()
  -- stylua: ignore start
  -- Draw cards method
  local function drawCard(card, x, y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(spst_enhancers, cardPlainQuad, x, y, 0, SPRITE_SCALE, SPRITE_SCALE)
    love.graphics.draw(spst_decks, card.quad, x, y, 0, SPRITE_SCALE, SPRITE_SCALE)
  end
  local function drawCardBack(x, y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(spst_enhancers, cardBackQuad, x, y, 0, SPRITE_SCALE, SPRITE_SCALE)
  end
  -- Draw Hit and Stand Buttons
  local function drawButton(button)
    if isMouseInButton(button) then love.graphics.setColor(1, 0.8, 0.3)
    else love.graphics.setColor(1, 0.5, 0.2) end
    love.graphics.rectangle( "fill", button.x, button.y, button.width, button.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print( button.text, button.x + button.textOffsetX, button.y + button.textOffsetY)
  end
  -- stylua: ignore end

  if not roundOver then
    drawButton(buttonHit)
    drawButton(buttonStand)
  else
    drawButton(buttonPlayAgain)
  end

  -- Draw Hands
  local cardSpacing = CARD_WIDTH * SPRITE_SCALE + 10
  local marginX = 10
  -- Draw dealer hand
  for cardIndex, card in ipairs(dealerHand) do
    local dealerMarginY = 30
    if not roundOver and cardIndex == 1 then
      drawCardBack(marginX + (cardIndex - 1) * cardSpacing, dealerMarginY)
    else
      drawCard(card, marginX + (cardIndex - 1) * cardSpacing, dealerMarginY)
    end
  end
  -- Draw player hand
  for cardIndex, card in ipairs(playerHand) do
    if card.quad == nil then
      print("draw player card: " .. card.rank .. " of " .. card.suit)
    end
    drawCard(card, ((cardIndex - 1) * cardSpacing) + marginX, 160)
  end

  -- Draw total score and winner
  love.graphics.setColor(0, 0, 0)
  if roundOver then
    love.graphics.print("Dealer Total: " .. getTotal(dealerHand), marginX, 10)

    -- Determine winner
    local playerTotal = getTotal(playerHand)
    local dealerTotal = getTotal(dealerHand)
    local winner = ""

    if playerTotal > 21 then
      winner = "Dealer Wins! (Player Bust)"
    elseif dealerTotal > 21 then
      winner = "Player Wins! (Dealer Bust)"
    elseif playerTotal > dealerTotal then
      winner = "Player Wins!"
    elseif dealerTotal > playerTotal then
      winner = "Dealer Wins!"
    else
      winner = "Push! (Tie)"
    end

    love.graphics.print(winner, marginX, 260)
  else
    love.graphics.print("Dealer Total: ?", marginX, 10)
  end
  love.graphics.print("Player Total: " .. getTotal(playerHand), marginX, 140)

  -- stylua: ignore
  love.graphics.print( "HiDPI Sacle: " .. love.window.getDPIScale(), marginX, 320)
  love.graphics.print("Sprite Path: " .. debugPath, marginX, 340)
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

function love.mousereleased()
  if not roundOver then
    -- Player
    if isMouseInButton(buttonHit) then
      takeCard(playerHand)
      if getTotal(playerHand) >= 21 then
        roundOver = true
      end
    elseif isMouseInButton(buttonStand) then
      roundOver = true
    end
    -- Dealer
    if roundOver then
      while getTotal(dealerHand) < 17 do
        takeCard(dealerHand)
      end
    end
  elseif isMouseInButton(buttonPlayAgain) then
    reset()
  end
end
