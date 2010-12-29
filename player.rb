#!/usr/bin/ruby -w

# ================================
# sudo apt-get install libsdl1.2-dev
# sudo apt-get install libsdl-mixer1.2-dev
# sudo gem install rubysdl
#
# Windows:
# Read:  http://www.kmc.gr.jp/~ohai/rubysdl_download.en.html
# 1) Download rubysdl-win32-bin on rubyforge (http://rubyforge.org/frs/?group_id=1006)
# 2) go to the directory and type ruby install_rubysdl.rb
# ================================

require 'rubygems'
require 'sdl'

class Player

  def initialize(sounds)
    SDL::init(SDL::INIT_AUDIO)
    SDL::Mixer.open(22050,SDL::Mixer::FORMAT_S16,2,4096)
    @sounds = Hash.new
    sounds.each_pair { |id, file|
      @sounds[id] = SDL::Mixer::Wave.load("sounds/"+file)
      }
  end

  def play(id)
    raise "Sound '#{id}' does not exists" if @sounds[id] == nil
    begin
      SDL::Mixer.play_channel(-1,@sounds[id],0)
    rescue # in case of too many sounds played and no more free channel
    end
  end

  def quit
    SDL::quit
  end

end

