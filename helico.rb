require 'vector'
require 'meter'

class Helico

  attr_reader :state
  attr_accessor :acc, :vert, :horiz, :speed, :pos

  def initialize(canvas, x, y)
    @canvas = canvas
    @ellipse = Gnome::CanvasEllipse.new(@canvas.root, {
      :fill_color_rgba => 0x000000FF})
    @pos        = MVector.new(x,y,0)
    @old_pos    = @pos

    pixbuf1 = Gdk::Pixbuf.new("images/helico-right.png")
    pixbuf2 = Gdk::Pixbuf.new("images/helico-left.png")
    @image_right  = Gtk::Image.new(pixbuf1)
    @image_left   = Gtk::Image.new(pixbuf2)
    #@image.modify_bg(Gtk::STATE_NORMAL, Gdk::Color.new(65000,0,0))
    @img_offset_x = @image_right.pixbuf.width/2
    @img_offset_y = @image_right.pixbuf.height
    @canvas.put(@image_right, @pos.x, @pos.y-100)
    @canvas.put(@image_left, @pos.x, @pos.y-100)

    @speed      = MVector.new
    @acc        = MVector.new(0, 0, 0)
    #@state      = :playing
    @vert       = nil
    @horiz      = nil
    @time       = Time.now
    @input      = 0.1
    @max_speed  = 0.4
    @max_descending_speed  =  0.2
    @max_ascending_speed   = -0.4
    @speed_meter  = Meter.new(@canvas, "Speed",   MVector.new(100, 580), 50, 0, @max_speed, 0)
    @vspeed_meter = Meter.new(@canvas, "V speed", MVector.new(220, 580), 50, 0, -@max_ascending_speed*2, Math::PI/2)
    @alt_meter    = Meter.new(@canvas, "Alt",     MVector.new(340, 580), 50, 0, 450, 0)
    update
  end

  def update
    time = Time.now-@time
    if @vert == :up;      @acc.y = -@input
    elsif @vert == :down; @acc.y =  @input*2
    else @acc.y =  @input
    end
    @acc.x = 0
    if @horiz == :right
      @acc.x =  @input
    elsif  @horiz == :left
      @acc.x = -@input
    end
    @speed   += @acc*time
    if @speed.y > @max_descending_speed;   @speed.y  = @max_descending_speed
    elsif @speed.y < @max_ascending_speed; @speed.y  = @max_ascending_speed
    end
    @speed.x *= 0.9995
    @speed = @speed.normalize*@max_speed if @speed.length > @max_speed
    @pos     += @speed

    #check_pos

    #@ellipse.x1 = @pos.x-Sizeby2
    #@ellipse.y1 = @pos.y-Sizeby2
    #@ellipse.x2 = @pos.x+Sizeby2
    #@ellipse.y2 = @pos.y+Sizeby2

    move if moved?

    @speed_meter.update(@speed.length)
    @vspeed_meter.update(-@speed.y)
    @alt_meter.update(-(@pos.y-450))

    @old_pos = @pos
    @time = Time.now
  end

  def move
    if @speed.x >= 0
      @canvas.move(@image_left, -100, -100)
      @canvas.move(@image_right, @pos.x-@img_offset_x, @pos.y-@img_offset_y)
    else
      @canvas.move(@image_right, -100, -100)
      @canvas.move(@image_left, @pos.x-@img_offset_x, @pos.y-@img_offset_y)
    end
  end

  def moved?
    return true if @speed.length > 0.006 #or @pos != @old_pos
    false
  end

  def check_pos
    if @pos.y > 600
      @pos.y    = 600
      @speed.y  = 0
    end
    if @pos.x < 0
      @pos.x = 0
      @speed.x  = 0
    elsif @pos.x > 580
      @pos.x = 580
      @speed.x  = 0
    end
  end

  def destroy
    @ellipse.destroy
  end

end

