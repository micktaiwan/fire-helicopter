#!/usr/bin/env ruby

require 'board'
require 'utils'
require 'player'
#require 'game'

# TODO: moving map
# TODO: dashboard with various meters (fuel, water level, speed)

@@player = Player.new(SOUNDS)

Gtk.init()
#game  = Game.new
board = Board.new(ARGV[1]=='admin')
view  = Viewer.new(board)
view.show
loop {
  board.iterate # if board.started
  break if board.destroyed?
  }

@@player.quit
#Gtk.main_quit


# (o-
# //\
# v_/_

