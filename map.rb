class Map

  attr_reader :ground

  def initialize(canvas)
    @canvas = canvas
    @ground = [[0, 550, 250, 550], [250, 550, 500, 300], [500, 300, 600, 300]]
    @lines = []
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

end

