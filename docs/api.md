# API Documentation

## Games

### POST: `/games/create` - Create a game

- **players** (required): This is the numbers of players (1-3 allowed) in a team (`Int`).
- **teams** (required): This JSON array contains the names of the 2 teams (`JSON`).

```
[
    { "name": "Alexander Delemarre" },
	{ "name" : "Hans Ott" }
]
```

**Returns**: The unique code of the created game (`String`).

### GET: `/games/:code` - Retrieve a game with given code

- **code** (required): This is the unique code of the game (`String`).

**Returns**: The game object

### GET: `/games/:id/info` - Retrieve a game with given id, this doesn't include the unique code

- **id** (required): The id of the game

**Returns**: The game object

## Teams

### PUT: `/teams/:id/score` - Increments (+1) the score of a team

- **id** (required): The id of the team
- **code** (required): This is the unique code of the game (`String`).
