# Wingspan

The overarching goal of this project is to develop an AI for wingspan. An AI can serve to discover new tactics and help humans get better, but also to provide a more challenging opposition than the AI available in the Steam Wingspan game. This AI will also eventually be able to play with Wingspan expansions which the current Steam version doesn't support.

Since there's a lack of good training data available, the AI will need to be trained and tuned through simulation. This means that developing a working Wingspan engine is required as part of this project. The engine should have an exposed API that I can hook an AI into, and a simplistic user interface.

The current plan is to implement an engine in Ruby that accepts commands and can output the current board state as JSON. Then a simple web interface in React or just plain JS can translate the JSON data into a human-readable visual game state.

## Training

There are a number of different ways to develop and train an AI for this game. I'll likely explore training a neural network with tensorflow, or trying a traditional gane AI method like MCTS or [ISMCTS](http://www.aifactory.co.uk/newsletter/2013_01_reduce_burden.htm).

I plan to use some spare Azure credit I have to accelerate training instead of using my own machine.

## High-level Capabilities

The engine needs some key features to contribute towards building an AI

- The engine should have a full understanding of Wingspan rules. There are always certain moves that are valid, and the engine needs to dictate what those moves are. For example, you cannot play out of turn, you cannot play a bird if you don't have enough food, and certain brown powers temporarily interupt the usual flow of turns (e.g. All players get a food from the birdfeeder). The engine should be able to keep track of all this state and always know who's turn it is and what their valid choices are.
- The engine needs to be able to serialize all board game state from the perspective of a single player. When an AI makes a decision, it has limited information. It does not know cards in other players hands and it does not know the next cards in the deck. To avoid "cheating" the engine should yield exactly the required data to the AIs and no more.
- The engine should have some sort of API. If I move forward with tensorflow the AI will likely be implemented in Python, while the engine is planned to be built in Ruby. I want to be able to implement AIs in any technology, so the engine should expose an API that can be used to view board state and make decisions. Since there may be multiple players and the AIs need to know when it's their turn, this could be implemented with a webhook system similar to [Battlesnake](https://play.battlesnake.com/). This type of system would make it easy to pit different AIs against eachother and see who wins.
- The engine should be able to calculate current and final scores.
- The engine should (eventually) support all birds. Figuring out how to do this without going crazy will take a bit of work but eventually the AI should support all birds.
- The engine should support a fixed "seed" or initial state and deck ordering. This would let us compare many AIs on a game with exactly the same RNG.

## Engine Interface

As disussed earlier, there are many ways to handle interfacing with the engine. Since this is a multiplayer game and players need to wait for their turn, a push model vs a pull model makes most sense. For that reason, I'll likely move forward with an HTTP webhook model similar to Battlesnake. This is how turns will happen:

- The game will be configured and started via some sort of API. The configuration will include:
  - Number of players, and their webhook URLs
  - Any rule customizations
  - Any seed data, like specific deck ordering
- The engine will send a "begin" message to each AI. This message will include important config options like number of players, and some unique game ID incase multiple games are happening simultaneously.
- The engine will keep track of all game state internally. If needed, this game state can be serialized to disk.
- The engine will figure out who's turn it is, and what their available moves are.
- It'll send them a request to their webhook URL with all the board state visible to that player (e.g. not including other players hands) + the current players score, and expect a response that specifies which move the player wants to take.
- The engine will modify internal state based on the players move decision, and then move on to the next player.
- The engine will disallow invalid moves, and may include a timeout. AIs that make invalid moves or timeout should be removed from the game.
- The engine will send game end messages indicating final scores and final board state.

## API Payloads

Note that integers representing indexes (like the current turn we're on) will be zero-indexed.

### Bird Power

The bird power object breaks down all information about a bird power so that clients don't need to parse power text and hard code all powers. If they can parse and understand the power rules, they can understand the powers for all birds.

```json
{
  # todo
}
```

### Bird Card

The card object represents a single bird card, and the different traits of the card.

```json
{
    birdId: 0,                      # A unique ID for the bird.
    name: "Acorn Woodpecker",        # The english name of the bird
    expansion: "original",           # original, european, or oceania
    cost: {                          # The birds cost
        invertabrate: 0,
        seed: 0,
        fish: 0,
        fruit: 0,
        rodent: 0,
        nectar: 0,
        wild: 0                      # A wild requirement can be satisfied with any food.
    },
    habitat: {                       # The habitats a bird can live in. It may live in multiple.
        forest: true,
        grassland: false,
        wetland: false,
    },
    color: "white",                  # The color of this birds power. Can be ["", "white", "brown", "pink", "yellow", "teal"]
    powerText: "Gain 1 [seed] from the birdfeeder (if available). You may cache it on this card.",
    power: {Bird Power},
    predator: false,
    flocking: false,
    victoryPoints: 5,
    nest: "cavity",                  # Nest type can be ["cavity", "platform", "ground", "bowl", "wild"]
    eggCapacity: 4,
    wingspan: 46,
    bonusCardEligibility: {          # Whether or not this card qualifies for different bonus cards
                                     # Note I may change this to be represented as a bit array / bool array instead of an object for space efficiency.
        anatomist: false,
        cartographer: false,
        historian: false,
        photographer: false,
        backyardBirder: false,
        birdBander: false,
        birdCounter: false,
        birdFeeder: true,
        dietSpecialist: true,
        enclosureBuilder: false,
        falconer: false,
        fisheryManager: false,
        foodWebExpert: false,
        forester: true,
        largeBirdSpecialist: false,
        nestBoxBuilder: true,
        omnivoreExpert: false,
        passerineSpecialist: false,
        platformBuilder: false,
        prairieManager: false,
        rodentologist: false,
        viticuluralist: false,
        wetlandScientist: false,
        wildlifeGardnerer: false
    }
}
```

### Bonus Card

The bonus card object represents one bonus card.

```json
{
    id: 0,
    name: "Anatomist",
    slug: "anatomist",           # Matches keys in bird card "BonusCardEligibility" list.
    description: "Birds with body parts in their names",
    milestones: [
        {
            points: 3,
            minimumToQualify: 2
        },
        {
            points: 7,
            minimumToQualify: 4
        }
    ],
    each: 0,                     # Some bonus cards give points per qualifying thing. 'each' is the number of points for each.
    percent: 22                  # Note that only bonus cards pertaining to bird cards have percentages.
}
```

### Card Slot

A card slot object represents a single slot where a card can be placed on a players board. A card slot can have a card, tucked cards, and eggs.

```json
{
    card: {Bird Card},                # Can be null
    eggs: 0,
    tuckedCards: 0,
    cachedFood: 0,
    secondHalfOfSidewaysCard: false   # A sideways card covers two card slots. This bool indicates that this bird card shouldn't be double counted when counting eggs, bonus cards, etc.
}
```

### Habitat

The habitat object represents one habitat on one players board. It tracks the card slots and stored nectar.

```json
{
    cardSlots: [                  # Exactly 5 card slots unless it's the "play bird" habitat.
        {Card Slot},
        ...
    ],
    cachedNectar: 0,
    cubes: 0                      # How many turn cubes have been spent activating this habitat this round?
}
```

### Board

The Board object represents one players board. All information on the board is visible to all players.

```json
{
    forest: {Habitat},
    grasslands: {Habitat},
    wetlands: {Habitat},
    playBird: {Habitat}
}
```

### Player

The player object represents one player. A player has a board, cards in hand, bonus cards, and different food resources.

```json
{
    board: {Board},
    birdCards: [             # [] if viewing from the perspective of another player.
        {Bird Card},
        ...
    ],
    bonusCards: [            # [] if viewing from the perspective of another player.
        {Bonus Card},
        ...
    ],
    food: {                  # Food available to spend.
        invertabrate: 0,
        seed: 0,
        fish: 0,
        fruit: 0,
        rodent: 0,
        nectar: 0
    },
    turnsRemaining: 4        # Turns remaining in round, includes the current turn for the current player.
}
```

### Round end goal

The round end goal represents a round end goal. The object stores enough information that clients don't need a full understanding of all round end goals, they can just parse the round end goal object.

```json
{
    ...
}
```

### Game state

The game state object represents the entirety of the game state, including every players board and overarching information like the round goals, current player, birdfeeder, etc.

Note that the board state payload sent to a specific player will never include cards in other player's hands.

```json
{
    game_id: "string",        # Unique string representing the current game.
    round: 0,                 # Round number, from 0 to 3 inclusive
    active_player: 0,         # Which players turn is it
    players: [                # List of all players
        {Player},
        ...
    ],
    visibleDeckCards: [       # 0 to 3 deck cards will be visible at any time
        {Bird Card},
        ...
    ],
    birdFeeder: {
        ... # need to learn about the different bird feeder dice
    },
    roundEndGoals: [          # Each index represents the round end goal for that turn. A goal may be null for no goal.
        {Round End Goal},
        ...
    ]
}
```