class Meter

  def initialize(canvas, text, pos, size, min,max, start_angle)
    @canvas     = canvas
    @pos, @size = pos, size
    @min, @max  = min, max
    @start_angle= start_angle
    #@arc = Gnome::Arc.new(@canvas.root,:filled=>false, :x1=>@pos.x-@size/2, :y1=>@pos.y-@size/2, :angle1=>-90, :angle2=>90)
    @arc = Gnome::CanvasBpath.new(@canvas.root,
      :outline_color => "black",
      :fill_color => 'steelblue')
    @arc.set_path_def(semi_circle_path(@pos.x,@pos.y))
    @needle = Gnome::CanvasLine.new(@canvas.root,
        :points => [[@pos.x, @pos.y], [@pos.x, @pos.y-@size]],
        :fill_color => "red",
        :width_pixels => 2.0)
    @level = Gnome::CanvasText.new(@canvas.root, {
      :x => @pos.x,
      :y => @pos.y+10,
      :fill_color=>"white",
      :family=>"Arial",
      :markup => text})
  end

  def update(value)
    angle = -(Math::PI - value/@max * Math::PI)
    x = @pos.x + Math.cos(angle+@start_angle)*@size*0.9
    y = @pos.y + Math.sin(angle+@start_angle)*@size*0.9
    @needle.points = [[@pos.x, @pos.y], [x, y]]
  end

private

  def semi_circle_path(x,y)
    p = Gnome::CanvasPathDef.new
    p.moveto(x-@size, y);
    p.lineto(x+@size, y);
    p.curveto(
      x+@size, y-@size*1.33,
      x-@size, y-@size*1.33,
      x-@size, y)
    p.closepath
    p
  end

end

