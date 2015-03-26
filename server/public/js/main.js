(function() {

    /* var id = document.getElementById('gameId').innerHTML;

    var socket = io();
    // var socket = io.connect('ip address');

    socket.on('responseGame', function(game) {
        document.getElementById('json').innerHTML = game.code;
        console.log(game);
    });

    socket.on('scoreUpdated', function(game) {
        console.log(game);
    });

    socket.emit('requestGame', id);
    socket.emit('subscribeToGame', id); */

    var gameId = $('#gameId').html();
    console.log(gameId);

    var app = angular.module('petanque', [
        'btford.socket-io',
    ]);

    app.factory('socket', function(socketFactory) {
        return socketFactory({
            // ioSocket: io.connect('ip address');
        });
    });

    app.controller('GameController', function($scope, socket) {

        socket.on('responseGame', function(game) {
            $scope.game = game;

            $('#json').html(game.code);
        });

        socket.on('scoreUpdated', function(game) {
            $scope.game = game;

            console.log(game);
        });

        socket.emit('requestGame', gameId);
        socket.emit('subscribeToGame', gameId);
    });

})();