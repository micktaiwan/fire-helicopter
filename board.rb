require 'gnomecanvas2'
require 'helico'
require 'map'
require 'utils'

# TODO: teams force indicator

@@accel_group = Gtk::AccelGroup.new

class Viewer < Gtk::Window
  def initialize(board)
    super()
    set_title("Fire Helcopter")
    signal_connect("delete_event") { |i,a| board.destroy } #; Gtk.main_quit }
    set_default_size(600,600)
    add_accel_group(@@accel_group)
    accel_group = @@accel_group
    add(board)
    show()
  end
end

class Board < Gtk::VBox

  attr_reader :virus, :level, :current_level
  #attr_accessor

  def initialize(is_admin)
    super()
    @circles        = []
    @box = Gtk::EventBox.new
    pack_start(@box)
    set_border_width(@pad = 0)
    set_size_request((@width = 48)+(@pad*2), (@height = 48)+(@pad*2))
    @canvas = Gnome::Canvas.new(true) # SWT.DOUBLE_BUFFERED | SWT.NO_BACKGROUND
    #@canvas.signal_connect("draw-background") {
    #  puts "draw"
    #  false
    #  }
    #@canvas.signal_connect("render-background") {
    #  puts "render"
    #  false
    #  }
    @canvas.double_buffered = false
    #@canvas.set_scroll_region(-1000,-1000, 1200,1200)
    #@canvas.set_pixels_per_unit(0.5)
    #@canvas.scroll_to(200,200)
    @box.add(@canvas)
    @box.set_visible_window(@canvas)
    @map = Map.new(@canvas)
    @helico = Helico.new(@canvas,170,439)
    @box.signal_connect('size-allocate') { |w,e,*b|
      @width, @height = [e.width,e.height].collect{|i|i - (@pad*2)}
      @canvas.set_size(@width,@height)
      @canvas.set_scroll_region(0,0,@width,@height)
      if not @bg
        @bg = Gnome::CanvasRect.new(@canvas.root, {
          :x1 => 0,
          :y1 => 0,
          :x2 => @width,
          :y2 => @height,
          :fill_color_rgba => 0x667788FF})
        @bg.lower_to_bottom
      else
        @bg.x2 = @width
        @bg.y2 = @height
      end
      false
      }
    @box.signal_connect('button-press-event') do |item, ev|
      @mouse_down = true
      false
    end
    @box.signal_connect('motion_notify_event') do |item,  ev|
      false
    end
    @box.signal_connect('button-release-event') do |item, ev|
      @mouse_down = nil
      false
    end
    @box.signal_connect('key-press-event') do |owner, ev|
      case ev.keyval
      when Gdk::Keyval::GDK_Escape
        @helico.pos.x, @helico.pos.y = 300, 300
      when Gdk::Keyval::GDK_Up
        @helico.vert = :up
      when Gdk::Keyval::GDK_Down
        @helico.vert = :down
      when Gdk::Keyval::GDK_Right
        @helico.horiz = :right
      when Gdk::Keyval::GDK_Left
        @helico.horiz = :left
      end
      false
    end
    @box.signal_connect('key-release-event') do |owner, ev|
      case ev.keyval
      when Gdk::Keyval::GDK_Down
        @helico.vert = nil
      when Gdk::Keyval::GDK_Up
        @helico.vert = nil
      when Gdk::Keyval::GDK_Right
        @helico.horiz = nil
      when Gdk::Keyval::GDK_Left
        @helico.horiz = nil
      end
      false
    end
    signal_connect_after('show') {|w,e| start() }
    signal_connect_after('hide') {|w,e| stop() }
    show_all()
  end

  def start
    @@player.play(:flying,-1,-1) # infinite loop
  	@started = true
  end

  def stop
  	@started = false
  end

  def iterate
    @helico.update
    @map.update
    check_map_offset
    check_collisions
    while (Gtk.events_pending?)
      Gtk.main_iteration
    end
  end

  def check_map_offset
    if @helico.pos.x > 350 and @helico.speed.x > 0
      off = @helico.speed.x*((350.0-@helico.pos.x)/100)
      @map.add_offset(off)
      @helico.pos.x += off
    end
    if @helico.pos.x < 250 and @helico.speed.x < 0
      off = @helico.speed.x*((@helico.pos.x-250.0)/100)
      @map.add_offset(off)
      @helico.pos.x += off
    end
  end

  def check_collisions
    s = @helico.speed*10
    @map.each_line { |line|
      p = get_intersection(line[0],line[1], line[2],line[3], @helico.pos.x,@helico.pos.y, @helico.pos.x+s.x,@helico.pos.y+s.y)
      if p and distance(@helico.pos.x, @helico.pos.y, p.x, p.y) <= 1
        if @helico.speed.length > 0.15
          @@player.play(:dead)
          puts "crash at speed #{@helico.speed.length}"
          @helico.speed.y   = -@helico.speed.y*0.8
          @helico.speed.x   *= 0.5
        elsif @helico.speed.length > 0.08
          @@player.play(:landing)
          @helico.speed.y   = -@helico.speed.y*0.8
          @helico.speed.x   *= 0.5
        else
          @helico.speed.y   = 0
          @helico.speed.x   *= 0.5
        end
        @helico.pos.y     = p.y-0.1
      end
      }
  end

end

