# ---
# cover: assets/airports_count.png
# author: bruno
# description: Locations of US Airports
# ---

using Deneb

usa = Data(
    url="https://vega.github.io/vega-datasets/data/us-10m.json",
    format=(type=:topojson, feature=:states),
) * Mark(
    :geoshape, fill=:lightgray, stroke=:white
)

points = Data(
    url="https://vega.github.io/vega-datasets/data/airports.csv"
) * Mark(:circle) * Transform(
    aggregate=[
        (op=:mean, field=:latitude, as=:latitude),
        (op=:mean, field=:longitude, as=:longitude),
        (op=:count, as=:count),
      ],
      groupby=[:state]
) * Encoding(
    longitude=:longitude,
    latitude=:latitude,
    detail=:state,
    size=field("count:Q", title="Number of Airports"),
)

base = projection("albersUsa") * vlspec(
    width=500,
    height=300,
    title="Number of Airports in US"
)

chart = base * (usa + points)

# save cover #src
save("assets/airports_count.png", chart) #src
