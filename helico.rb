require 'vector'

class Helico

  attr_reader :state
  attr_accessor :acc, :up, :right, :left, :speed, :pos
  Size    = 40
  Sizeby2 = Size / 2

  def initialize(canvas, x, y)
    @canvas = canvas
    @ellipse = Gnome::CanvasEllipse.new(@canvas.root, {
      :fill_color_rgba => 0x000000FF})
    @pos        = MVector.new(x,y,0)
    @speed      = MVector.new
    @acc        = MVector.new(0, 0, 0)
    #@state      = :playing
    @up         = false
    @right      = false
    @left       = false
    @time = Time.now
    update
  end

  def update
    time = Time.now-@time
    if @up
      @acc.y = -0.05
    else
      @acc.y = 0.05
    end
    @acc.x = 0
    if @right
      @acc.x = 0.05
    end
    if @left
      @acc.x = -0.05
    end
    @speed += @acc*time
    @speed.y = 0.05 if @speed.y > 0.05
    @speed.x *= 0.9999
    @pos += @speed
    check_pos
    @ellipse.x1 = @pos.x-Sizeby2
    @ellipse.y1 = @pos.y-Sizeby2
    @ellipse.x2 = @pos.x+Sizeby2
    @ellipse.y2 = @pos.y+Sizeby2
    @time = Time.now
  end

  def check_pos
    if @pos.y > 550
      @pos.y    = 550
      @speed.y  = 0
    end
    if @pos.x < 50
      @pos.x = 50
      @speed.x  = 0
    elsif @pos.x > 550
      @pos.x = 550
      @speed.x  = 0
    end
  end

  def destroy
    @ellipse.destroy
  end

end

