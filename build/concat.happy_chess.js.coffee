requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
    window.setTimeout callback, 1000 / 60
    return
)()

window.Game = {}

Game.columns = 9
Game.rows = 10
Game.margin_top  = 50
Game.margin_left = 50
Game.piece_padding = 60
Game.radius = 26
Game.is_debug = true
Game.log = (message) ->
  console.log('Chess: ', message) if Game.is_debug

#### Another file ####

class Piece
  constructor: (name_symbol, color) ->
    @name_symbol = name_symbol
    @is_selected = false
    @is_hover = false
    @name = if @name_symbol.indexOf('_') > -1 then @name_symbol.split('_')[0] else @name_symbol
    @color = color
    @point = new PiecePoint(@start_point().x, @start_point().y)
    @target_point = null

  set_point:(point) ->
    @point = point

  move_to_point: (target_point) ->
    @target_point = target_point

  update: (dt) ->
    if @target_point
      if @target_point.x != @point.x
        @point.x -= 1 if @target_point.x < @point.x
        @point.x += 1 if @target_point.x > @point.x
      if @target_point.y != @point.y
        @point.y -= 1 if @target_point.y < @point.y
        @point.y += 1 if @target_point.y > @point.y
      if @target_point.x == @point.x && @target_point.y == @point.y
        @set_point(@target_point)



  renderTo:(ctx) ->
    ctx.beginPath()
    ctx.arc(@point.x_in_world(), @point.y_in_world(), Game.radius, 0, 2 * Math.PI, false)
    ctx.fillStyle = @color
    ctx.fill()
    ctx.lineWidth = 5
    if @is_selected
      ctx.strokeStyle = '#FF9900'
    else
      if @is_hover
        ctx.strokeStyle = '#BDBDBD'
      else
        ctx.strokeStyle = '#003300'

    ctx.stroke()
    ctx.font = '20pt Calibri'
    ctx.fillStyle = '#FFF'
    ctx.textAlign = 'center'
    ctx.fillText(@label(), @point.x_in_world(), @point.y_in_world()+10)

  label: ->
    l = null
    if @name == 'car'
      l = if @color == 'red' then '车' else '車'
    if @name == 'horse'
      l = if @color == 'red' then '马' else '馬'
    if @name == 'elephant'
      l = if @color == 'red' then '象' else '相'
    if @name == 'knight'
      l = if @color == 'red' then '士' else '士'
    if @name == 'chief'
      l = if @color == 'red' then '将' else '帅'
    if @name == 'gun'
      l = if @color == 'red' then '炮' else '炮'
    if @name == 'soldier'
      l = if @color == 'red' then '兵' else '卒'
    l

  start_point: ->
    switch @name_symbol
      when 'car_l'      then {x:0,y:0}
      when 'car_r'      then {x:8,y:0}
      when 'horse_l'    then {x:1,y:0}
      when 'horse_r'    then {x:7,y:0}
      when 'elephant_l' then {x:2,y:0}
      when 'elephant_r' then {x:6,y:0}
      when 'knight_l'   then {x:3,y:0}
      when 'knight_r'   then {x:5,y:0}
      when 'chief'      then {x:4,y:0}
      when 'gun_l'      then {x:1,y:2}
      when 'gun_r'      then {x:7,y:2}
      when 'soldier_1'  then {x:0,y:3}
      when 'soldier_2'  then {x:2,y:3}
      when 'soldier_3'  then {x:4,y:3}
      when 'soldier_4'  then {x:6,y:3}
      when 'soldier_5'  then {x:8,y:3}
      when 'soldier_6'  then {x:9,y:3}

  active: ->
    @is_selected = true

  deactive: ->
    @is_selected = false

  hover: ->
    @is_hover = true

  hout: ->
    @is_hover = false

#### Another file ####

class PiecePoint

  constructor: (x, y) ->
    @x = x
    @y = y
    @is_hover = false

  x_in_world: ->
    @x * Game.piece_padding + Game.margin_left

  y_in_world: ->
    ((Game.rows-1) - @y) * Game.piece_padding + Game.margin_top

  is_same: (other) ->
    @x == other.x && @y == other.y

  hover: ->
    @is_hover = true

  hout: ->
    @is_hover = false

  renderTo:(ctx) ->
    if @is_hover
      ctx.beginPath()
      ctx.arc(@x_in_world(), @y_in_world(), 4, 0, 2 * Math.PI, false)
      ctx.lineWidth = 5
      ctx.strokeStyle = '#003300'
      ctx.stroke()

  is_at_top_edge: ->
    @y == 9

  is_at_bottom: ->
    @y == 0

  is_at_left_edge: ->
    @x == 0

  is_at_right_edge: ->
    @x == (Game.columns - 1)

  is_at_self_river: ->
    @y == 4

  is_at_enmy_river: ->
    @y == 5

  toPosition: ->
    {x : @x * Game.piece_padding, y : ((Game.rows-1) - @y) * Game.piece_padding  }

  toPositionInWorld: ->
    {x : @x * Game.piece_padding + Game.margin_left, y : ((Game.rows-1) - @y) * Game.piece_padding + Game.margin_top }

class Chess

  main: =>
    now = Date.now()
    dt = (now - @lastTime) / 1000.0
    @update dt
    @render()
    @lastTime = now
    requestAnimFrame @main
    return

  update: (dt) ->
    @current_points = []
    for piece in @pieces
      @current_points.push(piece.point)
      if @selected_piece == piece
        console.log('selected piece: ', piece.point.x, piece.point.y)
        if @target_point
          @selected_piece.move_to_point(@target_point)
          @selected_piece.update(dt)

  render: ->
    @ctx.fillStyle = '#FFF';
    @ctx.fillRect(0, 0, @ctx_width, @ctx_height)
    @drawMap()

    for point in @all_points
      point.renderTo(@ctx)

    for piece in @pieces
      piece.renderTo(@ctx)

  constructor: (canvas_id = 'chess_game') ->
    @lastTime = Date.now()
    @canvas_element = document.getElementById(canvas_id)
    @canvasElemLeft = @canvas_element.offsetLeft
    @canvasElemTop = @canvas_element.offsetTop
    @ctx = @canvas_element.getContext('2d')
    @ctx_width = 800
    @ctx_height = 600
    @margin_top = Game.margin_top
    @margin_left = Game.margin_left

    @piece_margin = Game.piece_padding

    @columns = Game.columns
    @rows = Game.rows

    @panel_width = (@columns - 1) * @piece_margin
    @panel_height = (@rows - 1) * @piece_margin

    @all_points = []
    @current_points = []
    @selected_piece = null
    @target_point
    Game.log("panel width, height: ", @panel_width, @panel_height)

  is_blank_point: (point) ->
    found = false
    for _point in @current_points
      found = true if point.is_same(_point)
      break

    return found == false

  point:(x, y) ->
    point = null
    for _point in @all_points
        if _point.x == x && _point.y == y
          point = _point
          break
    point

  fill_points: ->
    column_array = [0..(@columns-1)]
    row_array = [0..(@rows-1)]
    for y in row_array
      for x in column_array
        @all_points.push(new PiecePoint(x, y))

  init: ->
    @fill_points()
    @setupPieces()
    @setupEventListener()
    @main()

  drawMap: ->
    # First draw 4 edge borders
    lb_point = @point(0,0)
    rb_point = @point(8,0)
    lt_point = @point(0,9)
    rt_point = @point(8,9)
    @ctx.beginPath()
    @ctx.strokeStyle = '#000000'
    @ctx.lineWidth = 4
    @ctx.moveTo(lb_point.x_in_world(), lb_point.y_in_world())
    @ctx.lineTo(lt_point.x_in_world(), lt_point.y_in_world())
    @ctx.stroke()

    @ctx.beginPath()
    @ctx.moveTo(lt_point.x_in_world(), lt_point.y_in_world())
    @ctx.lineTo(rt_point.x_in_world(), rt_point.y_in_world())
    @ctx.stroke()

    @ctx.beginPath()
    @ctx.moveTo(rt_point.x_in_world(), rt_point.y_in_world())
    @ctx.lineTo(rb_point.x_in_world(), rb_point.y_in_world())
    @ctx.stroke()

    @ctx.beginPath()
    @ctx.moveTo(rb_point.x_in_world(), rb_point.y_in_world())
    @ctx.lineTo(lb_point.x_in_world(), lb_point.y_in_world())
    @ctx.stroke()

    # 2: Draw rows
    @ctx.strokeStyle = '#BDBDBD'
    @ctx.lineWidth = 1
    for _y in [1..8]
      left_edge_point = @point(0, _y)
      right_edge_point = @point(8, _y)
      @ctx.beginPath()
      @ctx.moveTo(left_edge_point.x_in_world(), left_edge_point.y_in_world())
      @ctx.lineTo(right_edge_point.x_in_world(), right_edge_point.y_in_world())
      @ctx.stroke()

    # 3: Draw self columns
    for _x in [1..7]
      b_point = @point(_x, 0)
      t_point = @point(_x, 4)
      @ctx.beginPath()
      @ctx.moveTo(b_point.x_in_world(), b_point.y_in_world())
      @ctx.lineTo(t_point.x_in_world(), t_point.y_in_world())
      @ctx.stroke()
    # 4: Draw enmy columns
    for _x2 in [1..7]
      b2_point = @point(_x2, 5)
      t2_point = @point(_x2, 9)
      @ctx.beginPath()
      @ctx.moveTo(b2_point.x_in_world(), b2_point.y_in_world())
      @ctx.lineTo(t2_point.x_in_world(), t2_point.y_in_world())
      @ctx.stroke()

    # 5: Draw self house line
    s1_point = @point(3,0)
    s11_point = @point(5,2)
    @ctx.beginPath()
    @ctx.moveTo(s1_point.x_in_world(), s1_point.y_in_world())
    @ctx.lineTo(s11_point.x_in_world(), s11_point.y_in_world())
    @ctx.stroke()
    s2_point = @point(5,0)
    s22_point = @point(3,2)
    @ctx.beginPath()
    @ctx.moveTo(s2_point.x_in_world(), s2_point.y_in_world())
    @ctx.lineTo(s22_point.x_in_world(), s22_point.y_in_world())
    @ctx.stroke()
    # 6: Draw enmy house line
    s3_point = @point(3,7)
    s33_point = @point(5,9)
    @ctx.beginPath()
    @ctx.moveTo(s3_point.x_in_world(), s3_point.y_in_world())
    @ctx.lineTo(s33_point.x_in_world(), s33_point.y_in_world())
    @ctx.stroke()
    s4_point = @point(5,7)
    s44_point = @point(3,9)
    @ctx.beginPath()
    @ctx.moveTo(s4_point.x_in_world(), s4_point.y_in_world())
    @ctx.lineTo(s44_point.x_in_world(), s44_point.y_in_world())
    @ctx.stroke()

  setupPieces: ->
    @pieces = []
    for name in ['car_l', 'car_r', 'horse_l', 'horse_r', 'elephant_l', 'elephant_r', 'knight_l', 'knight_r', 'chief', 'gun_l', 'gun_r', 'soldier_1', 'soldier_2', 'soldier_3', 'soldier_4', 'soldier_5']
      piece = new Piece(name, 'red')
      @pieces.push(piece)
      @current_points.push(piece.point)

  setupEventListener: ->
    @canvas_element.addEventListener 'mousemove', (event) =>
      x = event.pageX - @canvasElemLeft
      y = event.pageY - @canvasElemTop
      for piece in @pieces
        if x >= piece.point.x_in_world() - Game.radius && x <= piece.point.x_in_world() + Game.radius && y >= piece.point.y_in_world() - Game.radius && y <= piece.point.y_in_world() + Game.radius
          piece.hover()
        else
          piece.hout()

      for every_point in @all_points
        if x >= every_point.x_in_world() - Game.radius && x <= every_point.x_in_world() + Game.radius && y >= every_point.y_in_world() - Game.radius && y <= every_point.y_in_world() + Game.radius
          if @is_blank_point(every_point)
            every_point.hover()
        else
          every_point.hout()

    @canvas_element.addEventListener 'click', (event) =>
      x = event.pageX - @canvasElemLeft
      y = event.pageY - @canvasElemTop
      console.log('receive click event on canvas: ', x, y)
      for piece in @pieces
        if x >= piece.point.x_in_world() - Game.radius && x <= piece.point.x_in_world() + Game.radius && y >= piece.point.y_in_world() - Game.radius && y <= piece.point.y_in_world() + Game.radius
          piece.active()
          @selected_piece = piece
        else
          piece.deactive()

      for every_point in @all_points
        if x >= every_point.x_in_world() - Game.radius && x <= every_point.x_in_world() + Game.radius && y >= every_point.y_in_world() - Game.radius && y <= every_point.y_in_world() + Game.radius
          if @is_blank_point(every_point)
            @target_point = every_point
            break

$ ->
  chess_game = new Chess()
  window.t = chess_game

  chess_game.init()