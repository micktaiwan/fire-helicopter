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
    @canvas = Gnome::Canvas.new(true)
    @box.add(@canvas)
    @box.set_visible_window(@canvas)
    @map = Map.new(@canvas)
    @helico = Helico.new(@canvas,300,550)
    @box.signal_connect('size-allocate') { |w,e,*b|
      @width, @height = [e.width,e.height].collect{|i|i - (@pad*2)}
      @canvas.set_size(@width,@height)
      @canvas.set_scroll_region(0,0,@width,@height)
      @bg.destroy if @bg
      @bg = Gnome::CanvasRect.new(@canvas.root, {
        :x1 => 0,
        :y1 => 0,
        :x2 => @width,
        :y2 => @height,
        :fill_color_rgba => 0x667788FF})
      @bg.lower_to_bottom
      false
      }
    @box.signal_connect('button-press-event') do |owner, ev|
      @mouse_down = true
      false
    end
    @box.signal_connect('motion_notify_event') do |item,  ev|
      false
    end
    @box.signal_connect('button-release-event') do |owner, ev|
      @mouse_down = nil
      false
    end
    @box.signal_connect('key-press-event') do |owner, ev|
      case ev.keyval
      when Gdk::Keyval::GDK_Escape
        @helico.pos.x, @helico.pos.y = 300, 300
      when Gdk::Keyval::GDK_Up
        @helico.up = true
      when Gdk::Keyval::GDK_Right
        @helico.right = true
      when Gdk::Keyval::GDK_Left
        @helico.left = true
      end
      false
    end
    @box.signal_connect('key-release-event') do |owner, ev|
      case ev.keyval
      when Gdk::Keyval::GDK_Up
        @helico.up = false
      when Gdk::Keyval::GDK_Right
        @helico.right = false
      when Gdk::Keyval::GDK_Left
        @helico.left = false
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
    check_offset
    check_collisions
    while (Gtk.events_pending?)
      Gtk.main_iteration
    end
  end

  def check_offset
    if @helico.pos.x > 350 and @helico.speed.x > 0
      @map.add_offset(-@helico.speed.x)
      @helico.pos.x -= @helico.speed.x*((@helico.pos.x-350)/100)
    end
    if @helico.pos.x < 250 and @helico.speed.x < 0
      @map.add_offset(-@helico.speed.x)
      @helico.pos.x -= @helico.speed.x*((250-@helico.pos.x)/100)
    end
  end

  def check_collisions
    s = @helico.speed*10
    @map.each_line { |line|
      p = get_intersection(line[0],line[1], line[2],line[3], @helico.pos.x,@helico.pos.y, @helico.pos.x+s.x,@helico.pos.y+s.y)
      if p and distance(@helico.pos.x, @helico.pos.y, p.x, p.y) <= Helico::Sizeby2
        @@player.play(:dead) if @helico.speed.length > 0.04
        @helico.speed.y = 0
        @helico.speed.x *= 0.5
        @helico.pos.y -= 0.5
      end
      }
  end

end

