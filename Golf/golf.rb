require 'ruby2d' 

set title: "Golf", width: 1920, height: 1080

$v = 0
$angle = 0
$count = 0
$arrows = []

$song = Music.new('music.mp3')
$song.play
$song.loop = true

$shot = Music.new('shot.mp3')
$win = Music.new('win.mp3')

$ball_x = [1467, 272, 1025, 1645, 1635, 1385, 285, 1660, 693, 83]
$ball_y = [285, 953, 68, 889, 411, 165, 907, 853, 996, 372]
$hole_x = [456, 1684, 253, 226, 326, 163, 1369, 267, 411, 1566]
$hole_y = [236, 210, 944, 249, 943, 167, 457, 195, 321, 237]

MAP_0 = [
  { x: 300, y: 400, w: 200, h: 50 },
  { x: 800, y: 200, w: 100, h: 300 },
  { x: 1200, y: 600, w: 250, h: 40 }
]

MAP_1 = [
  { x: 512, y: 738, w: 146, h: 92 },
  { x: 1342, y: 284, w: 221, h: 61 },
  { x: 978, y: 612, w: 104, h: 173 }
]

MAP_2 = [
  { x: 167, y: 845, w: 188, h: 47 },
  { x: 1560, y: 320, w: 132, h: 198 },
  { x: 902, y: 140, w: 276, h: 58 }
]

MAP_3 = [
  { x: 689, y: 504, w: 243, h: 66 },
  { x: 1410, y: 822, w: 97, h: 134 },
  { x: 320, y: 210, w: 165, h: 89 }
]

MAP_4 = [
  { x: 1100, y: 390, w: 201, h: 72 },
  { x: 450, y: 880, w: 129, h: 156 },
  { x: 1600, y: 140, w: 92, h: 63 }
]

MAP_5 = [
  { x: 275, y: 640, w: 167, h: 51 },
  { x: 980, y: 300, w: 284, h: 140 },
  { x: 1500, y: 760, w: 118, h: 78 }
]

MAP_6 = [
  { x: 720, y: 120, w: 210, h: 95 },
  { x: 1300, y: 540, w: 160, h: 60 },
  { x: 390, y: 820, w: 99, h: 170 }
]

MAP_7 = [
  { x: 1580, y: 680, w: 140, h: 52 },
  { x: 840, y: 420, w: 260, h: 180 },
  { x: 220, y: 260, w: 110, h: 73 }
]

MAP_8 = [
  { x: 600, y: 900, w: 180, h: 44 },
  { x: 1450, y: 350, w: 125, h: 160 },
  { x: 300, y: 500, w: 230, h: 90 }
]

MAP_9 = [
  { x: 1000, y: 700, w: 205, h: 55 },
  { x: 170, y: 300, w: 150, h: 140 },
  { x: 1380, y: 180, w: 95, h: 120 }
]

MAPS = [MAP_0, MAP_1, MAP_2, MAP_3, MAP_4, MAP_5, MAP_6, MAP_7, MAP_8, MAP_9]

def generate_map(map_data)
  $blocks = []

  map_data.each do |b|
    block = Rectangle.new(
      x: b[:x],
      y: b[:y],
      width: b[:w],
      height: b[:h],
      color: 'blue'
    )

    $blocks << block
  end
end

def clear_map
  return unless $blocks

  $blocks.each(&:remove)
  $blocks.clear
end

$current_map = 0

bg = Image.new(
  'grass.jpg',
  x: 0,
  y: 0,
  width: 1920,
  height: 1080,
  z: 0,
)

$ball = Image.new(
  'ball.png',
  width: 50,
  height: 50,
  x: $ball_x[$current_map], 
  y: $ball_y[$current_map],
  z: 2
)

$hole = Image.new(
  'hole.png',
  width: 50,
  height: 50,
  x: $hole_x[$current_map], 
  y: $hole_y[$current_map],
  z: 1
)

$score = Text.new(
  "Score: #{$count}",
  x: 1700, y: 25,
  size: 50,
  color: 'white',
  z: 3
)

$exit = Image.new(
  'exit.png',
  width: 150,
  height: 50,
  x: 50,
  y: 25,
  z: 3,
)

$continue = Image.new(
  'continue.png',
  width: 200,
  height: 150,
  x: 200,
  y: -20,
  z: 3,
  opacity: 0
)

generate_map(MAP_0)

def move()
  $ball.x += Math.cos($angle) * $v
  $ball.y += Math.sin($angle) * $v

  if $ball.x <= 0
    $ball.x = 0
    $angle = Math::PI - $angle
    $v *= 0.8
  elsif $ball.x + $ball.width >= Window.width
    $ball.x = Window.width - $ball.width
    $angle = Math::PI - $angle
    $v *= 0.8
  end

  if $ball.y <= 0
    $ball.y = 0
    $angle = -$angle
    $v *= 0.8
  elsif $ball.y + $ball.height >= Window.height
    $ball.y = Window.height - $ball.height
    $angle = -$angle
    $v *= 0.8
  end

  $v *= 0.98 
  if $v < 0.1
    $v = 0
  end
end

def hit
  $blocks.any? do |b| 
    ($ball.x < b.x + b.width) &&
    ($ball.x + $ball.width > b.x) &&
    ($ball.y < b.y + b.height) &&
    ($ball.y + $ball.height > b.y)
  end
end

def hole_hit
  ($ball.x < $hole.x + $hole.width) &&
  ($ball.x + $ball.width > $hole.x) &&
  ($ball.y < $hole.y + $hole.height) &&
  ($ball.y + $ball.height > $hole.y)
end

on :mouse_up do |event|
  if event.button == :left
    $delta_x = $ball.x - Window.mouse_x
    $delta_y = $ball.y - Window.mouse_y
    $angle = Math.atan2($delta_y, $delta_x)

    v_square = ($delta_x ** 2) + ($delta_y ** 2)
    $v += Math.sqrt(v_square) * 0.05

    $arrow = Line.new(
      x1: $ball.x,
      y1: $ball.y,
      x2: $ball.x + $delta_x,
      y2: $ball.y + $delta_y,
      width: 10,
      color: "black",
      z: 2
    )

    $arrows << $arrow
  end
end 

on :mouse_down do |event|
    $arrows.each(&:remove)
    $arrows.clear 

    close if $exit.contains? Window.mouse_x, Window.mouse_y

    if $continue.contains? Window.mouse_x, Window.mouse_y
      $game_over.remove
      $continue.remove
    end
end

update do
  move()

  if hit()
    $angle += Math::PI
    $v *= 0.5
  end
  
  if hole_hit()
    clear_map()

    $current_map += 1
    if $current_map >= MAPS.length
      $current_map = 0 
    end

    generate_map(MAPS[$current_map])

    $ball.x = $ball_x[$current_map]
    $ball.y = $ball_y[$current_map]
    $hole.x = $hole_x[$current_map]
    $hole.y = $hole_y[$current_map]

    $v = 0

    $count += 1
    $score.remove
    $score = Text.new(
    "Score: #{$count}",
    x: 1700,
    y: 25,
    size: 50,
    color: 'white',
    z: 3
    )

    if $count >= 10
      $continue = Image.new(
      'continue.png',
      width: 200,
      height: 150,
      x: 200,
      y: -20,
      z: 3,
      )
      $game_over = Text.new(
      'Game Over!',
      x: 400,
      y: 450,
      size: 200,
      color: 'white',
      z: 4
      )
      $win.play
      $count = 0
    end

    $shot.play
    $shot.fadeout(2000)
    $song.play
  end
end
show

