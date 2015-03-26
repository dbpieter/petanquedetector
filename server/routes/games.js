var express = require('express');
var router = express.Router();
var app = require('../app');
var apiEvent = app.apiEvent;
var models  = require('../models');
var randomstring = require("randomstring");

// Config variables
var minAllowedPlayersInTeam = 1;
var maxAllowedPlayersInTeam = 3;

router.get('/', function(req, res) {

	models.Game.findAll({ include: [models.Team] }).success(function(games) {
		res.json(games);
	}).error(function() {
		res.json({ msg : 'Database error' }, 500);
		return;
	});

});

/* [POST] /games/create Create a new game
 * @param {JSON Array} teams - The teams to be created
 * @param {Int} players - The amount of players in a team
 * @returns {String} The unique code needed to update the game 
 */
router.post('/', function(req, res) {

	console.log('creating game...');

	// Validator rules
	req.checkBody('players', 'Players must be an integer (' + minAllowedPlayersInTeam + '-' + maxAllowedPlayersInTeam + ')').isInt().range(minAllowedPlayersInTeam, maxAllowedPlayersInTeam);
	req.checkBody('team1', 'This parameter cannot be empty').notEmpty();
	req.checkBody('team2', 'This parameter cannot be empty').notEmpty();

	// Validate params
	var errors = req.validationErrors();
	if (errors) {
		res.json(errors, 400);
		return;
	}

	// Get the params
	var players = req.param('players');
	var team1 = req.param('team1');
	var team2 = req.param('team2');

	// Create game
	models.Game.create({
		code: randomstring.generate(50)
	}).success(function(game) {

		// Create team 1
		models.Team.create({
			name: team1,
			players: players,
			score: 0,
		}).success(function(team) {
			team.setGame(game);

			// Create team 2
			models.Team.create({
				name: team2,
				players: players,
				score: 0,
			}).success(function(team) {
				team.setGame(game);
			}).error(function() {
				res.status(500).json({ msg: 'Could not create team 2' });
				return;
			});

		}).error(function() {
			res.status(500).json({ msg: 'Could not create team 1' });
			return;
		});

		console.log('success');

		// notify everyone that this game has updated
		apiEvent.emit('gameCreated', game.id);

		// return the unique game code to the user
		res.json(game.code);
		res.end();
		return;

	}).error(function() {
		res.status(500).json({ msg: 'Database error' });
		res.end();
		return;
	});
});

/* [GET] /games/:code Get game object with given Code
 * @param {String} code - The unique code of the game
 * @returns {Object} The game object
 */
router.get('/:code', function(req, res, next) {
	var code = req.param('code');

	if (!code || code.length != 50) {
		next();
	}

	// retrieve Game with specified code
	models.Game.find({
		where : { code: req.param('code') },
		include: [models.Team]
	}).success(function(game) {

		// if game does not exist
		if (!game) {
			res.status(404).json({ msg: 'This game does not exist' });
			return;
		}

		res.json(game);
		return;
	}).error(function() {
		// res.status(500).json({ msg: 'Database error' });
		// res.end();
		// return;
	});
});

/* [GET] /games/:id/info Get game object with given id, this does include the unique code
 * @param {Int} id - The id of the game
 * @returns {Object} The game object
 */
router.get('/:GameId', function(req, res) {
	var id = req.param('GameId');

	// retrieve Game with specified code
	models.Game.find({
		where : { id: id },
		include: [models.Team]
	}).success(function(game) {

		// if game does not exist
		if (!game) {
			res.status(404).json({ msg: 'This game does not exist' });
			return;
		}

		// IMPORTANT for security
		// TODO: Implement this in sequelize
		delete game['code'];

		res.json(game);
		return;

	}).error(function() {
		res.status(500).json({ msg: 'Database error' });
		return;
	});
});

module.exports = router;
