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
+ **defaultGamemode:** If not using maplist.txt, this will be the gamemode used for all mapvotes
+ **mapExcludes:** Exclude some maps from vote - for an example if you install a map pack you can easily exclude some maps

## MapList
If this exists then each map may also have an associated gamemode (or multiple gamemodes where one is randomly selected) that will be displayed on the vote buttons).
Maps and gamemodes are defined on separate lines in the format:
```
map1:gamemode1,gamemode2
map2:gamemode1
```
Note to devs: This format is used because string length limits mean that the file needs to be read line-by-line and this was just a simple way of doing it.
Should be created in data/lythos_mapvote/mapList.txt

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
* [Merrick King]
	* Option to change gamemode during a mapvote