//--- Require all variables ---
var fs = require('fs');
var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var validator = require('express-validator');
var cors = require('cors');
var models = require('./models/index');
var events = require('events');
var multer = require('multer')

//--- Event for API Call ---
var apiEvent = new events.EventEmitter();
module.exports.apiEvent = apiEvent;

//--- Get our route files ---
var routes = require('./routes/index');
var games = require('./routes/games');
var teams = require('./routes/teams');
var detectballs = require('./routes/detectballs')

//--- Start Express ---
var sslOptions = {
    key: fs.readFileSync('./ssl/petanque.private.pem'),
    cert: fs.readFileSync('./ssl/petanque.public.pem'),
    requestCert: false,
    rejectUnauthorized: false
};

var app = express();
var http = require('http').Server(app);
var https = require('https').Server(sslOptions, app);
var io = require('socket.io')(https);

//--- SYNC Database and Start listening ---
models.sequelize.sync({ force : true }).success(function () {
  http.listen(80, function() {
      console.log('HTTP Server listening on port 80');
  });

  https.listen(443, function() {
      console.log('HTTPS Server listening on port 443');
  });
});

//--- Setup view engine (Jade) ---
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

//--- Allow PUT, DELETE etc ---
app.use(cors());

app.use( multer({dest: './uploads/'}));

//---  Register the validator and create custom validators ---
app.use(validator({
 customValidators: {
    isJSON: function(value) {
        try {
            JSON.parse(value);
        } catch (e) {
            return false;
        }
        return true;
    }, 
    range: function(value, min, max) {
        if (value >= min && value <= max) {
            return true;
        }
        return false;
    },
    isPositive: function(value) {
        if (value < 0) {
            return false;
        }
        return true;
    }
 }   
}));

app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


//--- Main Routes ---
app.use('/', routes);

//--- API Routes ----
app.use('/api/games', games);
app.use('/api/teams', teams);
app.use('/api/detectballs',detectballs)


//--- Socket.io ---
io.on('connection', function(client) {
    //--- Client connected ---
    console.log('Client connected');

    client.on('subscribeToGame', function(gameId) {
        client.join(gameId);
        console.log('Client subscribed to game ' + gameId);
    });

    apiEvent.on('scoreUpdated', function(gameId) {

        console.log('Score of game ' + gameId + ' is changed, sending changes to all subscribers');

        models.Game.find({
            where : { id : gameId },
            include: [models.Team]
        }).success(function(game) {
            if (game) {
                client.emit('scoreUpdated', game);
            }
        }).error(function() {

        });

    });

    client.on('requestGame', function(gameId) {

        models.Game.find({
            where : { id : gameId },
            include: [models.Team]
        }).success(function(game) {
            if (game) {
                client.emit('responseGame', game);
            }
        }).error(function() {

        });

    });

    //--- Client disconnected ---
    client.on('disconnect', function() {
        console.log('Client disconnected');
    });
});

//--- catch 404 and forward to error handler ---
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});


//--- Error handlers ---

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});