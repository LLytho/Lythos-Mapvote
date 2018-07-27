# Steam
You can find the addon on the workshop:
http://steamcommunity.com/sharedfiles/filedetails/?id=943738100

Check out my other addons:
http://steamcommunity.com/id/lytho_/myworkshopfiles/?appid=4000

# Lythos-Mapvote
Mapvote with map icons. Integrated in ULX.
You can easily call the mapvote through ULX.

# Config
The config will be generated after first initialize.
## Mapvote
Stored in data/lythos_mapvote/config.txt as JSON.

+ **mapRevoteBanRounds:** Amount of rounds the map cannot be vote again (*default 4*)
+ **mapsToVote:** Amount of maps to vote for (*default 10*)
+ **voteTime:** Vote time (*default 20*)
+ **mapPrefixes:** Only show maps with given prefixes (*default ttt_*)
+ **mapExcludes:** Exclude some maps from vote - for an example if you install a map pack you can easily exclude some maps

## RockTheVote
Stored in data/lythos_mapvote/rtv.txt as JSON.

+ **minVote:** Min vote to run mapvote (*default 3*)
+ **maxVote:** Max vote to run mapvote (*default 7*)
+ **percentage:** Percentage between 0 and 1 to choose min votes (*default 0.7*)
+ **minPlaytime:** Playtime before allow RockTheVote in seconds (*default 180*)

# Todo
* random map selection (Something like a roulette)
* smoother vote selection
* load maps images from a server

# Credits
* [Fresh Garry](https://steamcommunity.com/profiles/76561198125279214/)
    * Option to change UI size