# Japan Ski Resort API documentation
The Japan Ski Resort API provide important information about ski resorts in Japan for skiers and snowboarders.

## Base URL
The base URL of the API is `http://localhost:3000/api/v1/resorts`

## GET all resorts
To get the list of all Japan ski reosrts use base URL 
`GET http://localhost:3000/api/v1/resorts`

This will give you the JSON file of all the resort currently in the database:
```
[
    {
        "id": 1,
        "name": "Jiigatake",
        "prefecture": "Nagano"
    },
    {
        "id": 2,
        "name": "Kashimayari Snow Resort Family Park",
        "prefecture": "Nagano"
    },
    {
        "id": 3,
        "name": "White Resort HAKUBA SANOSAKA",
        "prefecture": "Nagano"
    }
]
```

## Get ONE resort
To get more details about one Japan ski resort, use the ID of found on the list of ski resort
` GET http://localhost:3000/api/v1/resorts/:id`

This you will the JSON file of all the details about the resort:
```
{
    "id": 1,
    "name": "Jiigatake",
    "prefecture": "Nagano",
    "town": "Hakuba",
    "address": "4819 Taira, Omachi, Nagano 398-0001",
    "trail_length": 4800,
    "longest_trial": 1500,
    "number_of_trails": 7,
    "lift": 4,
    "gondola": 0,
    "skiable_terrain": 30,
    "vertical_drop": 260,
    "base_altitude": 940,
    "highest_altitude": 1200,
    "steepest_gradient": 28,
    "difficulty_green": 70,
    "difficulty_red": 30,
    "difficulty_black": 0,
    "terrain_park": false
}
```

## Happy API
