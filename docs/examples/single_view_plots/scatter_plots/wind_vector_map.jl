# ---
# cover: assets/wind_vector_map.png
# author: bruno
# description: Wind Vector Map
# generate_cover: true
# ---

using Deneb

data = Data(
    url="https://cdn.jsdelivr.net/npm/vega-datasets/data/windvectors.csv",
    format=(type=:csv, parse=(longitude=:number, latitude=:number)),
)

chart = data * Mark(
    :point, shape=:wedge, filled=true,
) * Encoding(
    longitude=:longitude,
    latitude=:latitude,
    color=field(
        "dir:q",
        scale=(domain=[0, 360], scheme=:rainbow),
        legend=nothing
    ),
    angle=field(
        "dir:q",
        scale=(domain=[0, 360], range=[180, 540]),
    ),
    size=field("speed:q", scale=(; rangeMax=500)),
) * vlspec(
    width=625, height=560,
)

# save cover #src
save("assets/wind_vector_map.png", chart) #src
