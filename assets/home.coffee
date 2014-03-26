class @HomeView
  constructor: ->
    @controls = $("#controls")
    @buildControls()
    @promptName()
    @keyboardBindings()
    @grid = new Grid

  buildControls: ->
    @controls.html $("<input id='choose_name' type='text' placeholder='type a name'/><button id='name_chosen'>GO!</button>")

  promptName: ->
    @buildControls()
    @controls.on 'click', '#name_chosen', ()=>
      @name = $('#choose_name').val()
      return alert('please choose a name!') unless @name
      @addPacman()

  keyboardBindings: ->
    $(window).on 'keyup', (e)=>
      console.log e.key

  turn: (direction)->
    $.ajax "pacmans/turn/#{name}/#{direction}",
      type: "PUT"

  addPacman: ->
    $.post "/pacmans/add/#{@name}"

class Grid
  constructor: ->
    @$el = $('#grid')
    @buildCells()
    @startStream()

  buildCells: ->
    add_x = (y)=> @add(x, y) for x in [0..19]
    add_x(y) for y in [0..19]

  add: (x,y)->
    @["cell-#{x}-#{y}"] = $("<div class='cell' id='#{x}_#{y}' />")
    @$el.append @["cell-#{x}-#{y}"]

  all: ->
    $(".cell", @$el)

  cell:(x,y)->
    @["cell-#{x}-#{y}"]

  updateOne: (pacman)->
    x = pacman.position.x
    y = pacman.position.y
    @all().removeClass(name) for name in @names
    @cell(x,y).addClass(pacman.name)
    console.log @cell(x,y)

  update: (event)=>
    console.log event.data
    pacmans = JSON.parse event.data
    if pacmans.length > 0
      console.log "aho!", pacmans
      @names = (pacman.name for pacman in pacmans)
      @updateOne(pacman) for pacman in pacmans

  startStream: ->
    source = new EventSource('pacmans/stream');
    console.log source
    source.addEventListener 'message', @update, false
    # (e) {
    # //  console.log(e.data);
    # //}, false);
