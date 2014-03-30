// Generated by CoffeeScript 1.7.1
(function() {
  var Grid, Utils,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Utils = {
    randomColor: function() {
      var color, i, letters, _i;
      letters = '0123456789ABCDEF'.split('');
      color = '#';
      for (i = _i = 0; _i <= 5; i = ++_i) {
        color += letters[Math.round(Math.random() * 15)];
      }
      return color;
    },
    randomNumber: function() {
      var i, id, len, seed, _i;
      seed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".split('');
      len = seed.length;
      id = "";
      for (i = _i = 0; _i <= 14; i = ++_i) {
        id += seed[Math.round(Math.random() * seed.length)];
      }
      return id;
    }
  };

  this.HomeView = (function() {
    _.extend(HomeView.prototype, Utils);

    function HomeView() {
      this.running = false;
      this.$controls = $("#controls");
      this.color = this.randomColor();
      this.buildControls();
      this.promptName();
      this.keyboardBindings();
      this.id = this.randomNumber();
      this.grid = new Grid(this.id);
    }

    HomeView.prototype.buildControls = function() {
      return this.$controls.html($("<input id='choose_name' type='text' placeholder='type a name'/><button id='name_chosen' style='background-color:" + this.color + "'>GO!</button>"));
    };

    HomeView.prototype.promptName = function() {
      this.buildControls();
      return this.$controls.on('click', '#name_chosen', (function(_this) {
        return function() {
          if (_this.running) {
            return;
          }
          _this.name = $('#choose_name').val();
          if (!_this.name) {
            return alert('please choose a name!');
          }
          return _this.addPacman();
        };
      })(this));
    };

    HomeView.prototype.keyboardBindings = function() {
      return $(window).on('keyup', (function(_this) {
        return function(e) {
          return console.log(e.key);
        };
      })(this));
    };

    HomeView.prototype.turn = function(direction) {
      return $.ajax("pacmans/turn/" + name + "/" + direction, {
        type: "PUT"
      });
    };

    HomeView.prototype.addPacman = function() {
      $.post("/pacmans/add/" + this.name);
      this.running = true;
      this.updateButton();
      return this.grid.addName(this.name, this.color);
    };

    HomeView.prototype.updateButton = function() {
      return $("#name_chosen", this.$controls).attr('disabled', this.running);
    };

    return HomeView;

  })();

  Grid = (function() {
    _.extend(Grid.prototype, Utils);

    function Grid(id) {
      this.update = __bind(this.update, this);
      this.$el = $('#grid');
      this.buildCells();
      this.startStream(id);
      this.names = [];
    }

    Grid.prototype.addName = function(name, color) {
      this.names.push(name);
      return this.addColorRule(name, color);
    };

    Grid.prototype.addColorRule = function(name, color) {
      var styles;
      styles = document.styleSheets[0];
      return styles.addRule("." + name, "background: " + color, 0);
    };

    Grid.prototype.updateNames = function(names) {
      var name, newNames, _i, _len, _results;
      newNames = _.difference(names, this.names);
      if (_.isEmpty(newNames)) {
        return;
      }
      _results = [];
      for (_i = 0, _len = newNames.length; _i < _len; _i++) {
        name = newNames[_i];
        _results.push(this.addName(name, this.randomColor()));
      }
      return _results;
    };

    Grid.prototype.buildCells = function() {
      var add_x, y, _i;
      add_x = (function(_this) {
        return function(y) {
          var x, _i, _results;
          _results = [];
          for (x = _i = 0; _i <= 19; x = ++_i) {
            _results.push(_this.add(x, y));
          }
          return _results;
        };
      })(this);
      for (y = _i = 0; _i <= 19; y = ++_i) {
        add_x(y);
      }
      return this.cells = $(".cell", this.$el);
    };

    Grid.prototype.add = function(x, y) {
      this["cell-" + x + "-" + y] = $("<div class='cell' id='" + x + "_" + y + "' />");
      return this.$el.append(this["cell-" + x + "-" + y]);
    };

    Grid.prototype.cell = function(x, y) {
      return this["cell-" + x + "-" + y];
    };

    Grid.prototype.updateOne = function(pacman) {
      var x, y;
      x = pacman.position.x;
      y = pacman.position.y;
      this.cells.removeClass(pacman.name);
      this.cell(x, y).addClass(pacman.name);
      return console.log(this.cell(x, y));
    };

    Grid.prototype.update = function(event) {
      var pacman, pacmans, _i, _len, _results;
      console.log(event.data);
      return true;
      pacmans = JSON.parse(event.data);
      if (pacmans.length > 0) {
        this.updateNames((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = pacmans.length; _i < _len; _i++) {
            pacman = pacmans[_i];
            _results.push(pacman.name);
          }
          return _results;
        })());
        console.log("aho!", this.names);
        _results = [];
        for (_i = 0, _len = pacmans.length; _i < _len; _i++) {
          pacman = pacmans[_i];
          _results.push(this.updateOne(pacman));
        }
        return _results;
      }
    };

    Grid.prototype.errback = function(e) {
      return console.log(e);
    };

    Grid.prototype.startStream = function(id) {
      var source;
      source = new EventSource("pacmans/stream/" + id);
      source.addEventListener('message', this.update, false);
      return source.addEventListener('error', this.errback, false);
    };

    return Grid;

  })();

}).call(this);
