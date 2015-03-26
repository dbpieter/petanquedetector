"use strict";

module.exports = function(sequelize, DataTypes) {
  var Game = sequelize.define("Game", {
    code: DataTypes.STRING
  }, {
    classMethods: {
      associate: function(models) {
        Game.hasMany(models.Team)
      }
    }
  });

  return Game;
};