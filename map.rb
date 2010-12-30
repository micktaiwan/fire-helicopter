class Map

  attr_reader :ground

  def initialize(canvas)
    @canvas         = canvas
    @ground         = [[-2500, -1000, -2500, 550], [-2500, 550, -1500, 550],
                      [-1500, 550, -500, 150], [-500, 150, 0, 550],
                      [0, 550, 350, 550], [350, 550, 500, 300],
                      [500, 300, 800, 300], [800, 300, 1200, 400],
                      [1200, 400, 2200, 400], [2200, 400, 2200, -1000]]
    @lines          = []
    @offset         = 0.0
    @offset_speed   = 0.0
    @current_offset = 0.0
    init
  end

  def init
    clear
    @ground.each { |p|
      @lines <<  Gnome::CanvasLine.new(@canvas.root,
        :points => [[p[0], p[1]], [p[2], p[3]]],
        :fill_color => "black",
        :width_pixels => 2.0)
      }
  end

  def clear
    @lines.each { |l| l.destroy }
    @lines = []
  end

  def each_line
    @ground.each { |l|
      yield [l[0]+@current_offset, l[1], l[2]+@current_offset, l[3]]
      }
  end

  def add_offset(o)
    set_offset(@offset+o)
  end

  def set_offset(o)
    @offset = o.to_f
    @offset_speed = (@offset - @current_offset)# / 100
  end

  def update
    #return if @current_offset == @offset
    @current_offset += @offset_speed
    @ground.each_with_index { |p,i|
      @lines[i].points = [[p[0]+@current_offset, p[1]], [p[2]+@current_offset, p[3]]]
      }
  end

end

