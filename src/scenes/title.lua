local core = require 'hawk/core'
local middle = require 'hawk/middleclass'

local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'
local timer = require 'vendor/timer'

local window = require 'window'
local fonts = require 'fonts'
local camera = require 'camera'
local controls = require 'controls'
local menu = require 'menu'

local Title = middle.class('Title', core.Scene)

function Title:initialize(app)
  self.app = app
  self.cityscape = love.graphics.newImage("images/menu/cityscape.png")
  self.logo = love.graphics.newImage("images/menu/logo.png")
  self.splash = love.graphics.newImage("images/openingmenu.png")
  self.arrow = love.graphics.newImage("images/menu/small_arrow.png")
  self.logo_position = {y=-self.logo:getHeight()}
  self.logo_position_final = self.logo:getHeight() / 2 + 40
  self.text = ""
  tween(4, self.logo_position, { y=self.logo_position_final})

  self.menu = menu.new({ 'start', 'controls', 'options', 'credits', 'exit' })
  self.menu:onSelect(function(option)
    if option == 'exit' then
      love.event.push("quit")
    elseif option == 'start' then
      Gamestate.switch('scanning')
    elseif option == 'controls' then
      app:loadScene('modify_controls')
    else
      app:loadScene(option)
    end
  end)

  -- 'double_speed' is used to speed up the animation of the logo + splash
  self.double_speed = false
end


function Title:show()
  fonts.set( 'big' )

  local j = controls.getKey('JUMP')
  local a = controls.getKey('ATTACK')

  self.text = string.format(self.app.i18n('s_or_s_select_item'), j, a)

  camera:setPosition(0, 0)
  self.bg = sound.playMusic( "opening" )
end

function Title:hide()
  fonts.reset()

  if self.handle then 
    timer.cancel(self.handle)
  end
end

function Title:buttonpressed(button)
  if self.logo_position.y < self.logo_position_final then
    self.double_speed = true
  else
    self.menu:keypressed(button) 
  end
end

function Title:update(dt)
  if self.double_speed then
    tween.update(dt * 20)
  end
end

function Title:draw()
  love.graphics.draw(self.cityscape)
  love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
  window.height / 2 - self.logo_position.y)

  if self.logo_position.y >= self.logo_position_final then
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.text, 0, window.height - 32, window.width, 'center', 0.5, 0.5)
    love.graphics.setColor(255, 255, 255)
  end

  local x = window.width / 2 - self.splash:getWidth()/2
  local y = window.height / 2 + self.logo:getHeight() - self.logo_position.y + 5
  love.graphics.draw(self.splash, x, y)

  for n,option in ipairs(self.menu.options) do
    love.graphics.print(self.app.i18n(option), x + 23, y + 12 * n - 2, 0, 0.5, 0.5)
  end

  love.graphics.draw(self.arrow, x + 12, y + 23 + 12 * (self.menu:selected() - 1))
end

return Title