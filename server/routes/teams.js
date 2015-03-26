var express = require('express');
var router = express.Router();
var app = require('../app');
var apiEvent = app.apiEvent;
var models  = require('../models');

/* [GET] Get all teams */
router.get('/', function(req, res) {
	models.Team.findAll().success(function(teams) {
		res.json(teams);
		return;
	}).error(function() {
		res.json({ msg: 'Database error' }, 500);
	});
});

/* [GET] Get team object /teams/:id */
router.get('/:teamId', function(req, res) {
	var teamId = req.param('teamId');

	models.Team.find({
		where : { id : teamId }
	}).success(function(team) {
		res.json(team);
		return;
	}).error(function() {
		res.status(404).json({ msg: "Team does not exist" });
		return;
	});
});

/* [PUT] Update score of a team /teams/:id */
router.put('/:teamId', function(req, res) {
	var code = req.param('code');
	var teamId = req.param('teamId');
	var score = req.param('score');

	// TODO Check if positive

	// Find the required team
	models.Team.find({
		where : { id : teamId }
	}).success(function(team) {

		// if team does not exist
		if (!team) {
			res.json({ msg: 'Team not found' }, 404);
			return;
		}

		// Get the team
		team.getGame().success(function(game) {

			// if the game of the team does not exist
			if (!game) {
				res.json({ msg: 'Game not found' }, 404);
				return;
			}

			if (game['code'] == code) {
				team.score = score;

				team.save().success(function() {
					apiEvent.emit('scoreUpdated', game.id);

					res.json({ msg: 'Team has been updated' });
					res.end();
					return;
				}).error(function() {
					res.status(500).json({ msg: 'Could not update game' });
					res.end();
					return;
				});
			}
			else {
				res.status(401).json({ msg: 'Not authorized' });
				res.end();
				return;
			}
		});

		
	}).error(function() {
		res.status(403).json({ msg: 'Database error' });
		res.end();
		return;
	});
});

module.exports = router;