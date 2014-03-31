Utils =
  randomColor: ->
    letters = '0123456789ABCDEF'.split('')
    color = '#'
    color+= letters[Math.round(Math.random() * 15)] for i in [0..5]
    color

  randomNumber: ->
    seed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".split('')
    len = seed.length
    id = ""
    id += seed[Math.round(Math.random() * seed.length)] for i in [0..14]
    id

class @HomeView
  _.extend(@prototype, Utils)

  constructor: ->
    @running = false
    @$controls = $("#controls")
    @color = @randomColor()
    @buildControls()
    @promptName()
    @keyboardBindings()
    @id = @randomNumber()
    @grid = new Grid(@id)

  buildControls: ->
    @$controls.html $("<input id='choose_name' type='text' placeholder='type a name'/><button id='name_chosen' style='background-color:#{@color}'>GO!</button>")

  promptName: ->
    @buildControls()
    @$controls.on 'click', '#name_chosen', ()=>
      return if @running
      @name = $('#choose_name').val()
      return alert('please choose a name!') unless @name
      @addPacman()

  keyboardBindings: ->
    dirMap =
      37: "left"
      38: "up"
      39: "right"
      40: "down"
    $(window).on 'keyup', (e)=>
      key = "#{e.which}"
      return unless _.include( _.keys(dirMap), key)
      console.log "key:", e.which, (dir = dirMap[key])
      @turn dir

  turn: (direction)->
    $.ajax "pacmans/turn/#{@name}/#{direction}",
      type: "PUT"

  addPacman: ->
    $.post "/pacmans/add/#{@name}"
    @running = true
    @updateButton()
    @grid.addName(@name, @color)

  updateButton: ->
    $("#name_chosen", @$controls).attr('disabled', @running)

class Grid
  _.extend(@prototype, Utils)

  constructor: (id)->
    @$el = $('#grid')
    @buildCells()
    @startStream(id)
    @names = []

  addName: (name, color)->
    @names.push name
    @addColorRule name, color

  addColorRule: (name, color)->
    styles = document.styleSheets[0]
    styles.addRule(".#{name}", "background: #{color}", 0);

  updateNames:(names) ->
    newNames = _.difference names, @names
    return if _.isEmpty(newNames)
    @addName(name, @randomColor()) for name in newNames

  buildCells: ->
    add_x = (y)=> @add(x, y) for x in [0..19]
    add_x(y) for y in [0..19]
    @cells = $ ".cell", @$el

  add: (x,y)->
    @["cell-#{x}-#{y}"] = $("<div class='cell' id='#{x}_#{y}' />")
    @$el.append @["cell-#{x}-#{y}"]

  cell:(x,y)->
    @["cell-#{x}-#{y}"]

  updateOne: (pacman)->
    x = pacman.position.x
    y = pacman.position.y
    @cells.removeClass pacman.name
    @cell(x,y).addClass pacman.name

  update: (event)=>
    pacmans = JSON.parse event.data
    if pacmans.length > 0
      @updateNames(pacman.name for pacman in pacmans)
      @updateOne(pacman) for pacman in pacmans

  errback: (e)=>
    console.log e

  startStream: (id)->
    source = new EventSource("pacmans/stream/#{id}")
    source.addEventListener 'message', @update, false
    source.addEventListener 'error', @errback, false