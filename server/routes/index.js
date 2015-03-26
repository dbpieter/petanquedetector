var express = require('express');
var router = express.Router();
var models  = require('../models');

/* GET View Home page */
router.get('/', function(req, res) {
    if (!req.secure) {
        res.redirect('https://' + req.headers.host + req.url);
    }

    res.render('index');
});

/* GET View game details */
router.get('/:gameId', function(req, res) {
    if (!req.secure) {
        res.redirect('https://' + req.headers.host + req.url);
    }

    var gameId = req.param('gameId');

    models.Game.find({
        where: { id: gameId },
        include: [models.Team]
    }).success(function(game) {

        if (!game) {
            res.send('Game does not exist');
        }
        else {
            res.render('game', { gameId: game.id });
        }

    }).error(function() {
        res.send('Database error, please try again later.');
    });
    
});

module.exports = router;
