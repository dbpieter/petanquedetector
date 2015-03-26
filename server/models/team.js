"use strict";

module.exports = function(sequelize, DataTypes) {

  var Team = sequelize.define("Team", {
    name: DataTypes.STRING,
    score: DataTypes.INTEGER,
    players: DataTypes.INTEGER
  }, {
    classMethods: {
      associate: function(models) {
        Team.belongsTo(models.Game);
      }
    }
  });

  return Team;
};