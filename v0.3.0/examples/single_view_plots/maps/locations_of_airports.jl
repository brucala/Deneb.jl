using Deneb

usa = Data(
    url="https://vega.github.io/vega-datasets/data/us-10m.json",
    format=(type=:topojson, feature=:states),
) * Mark(
    :geoshape, fill=:lightgray, stroke=:white
)

points = Data(
    url="https://vega.github.io/vega-datasets/data/airports.csv"
) * Mark(:circle) * transform_aggregate(
    latitude="mean(latitude)",
    longitude="mean(longitude)",
    count="count()",
    groupby=:state,
) * Encoding(
    longitude=:longitude,
    latitude=:latitude,
    detail=:state,
    size=field("count:Q", title="Number of Airports"),
)

base = projection("albersUsa") * vlspec(
    width=500,
    height=300
) * title("Number of Airports in US")

chart = base * (usa + points)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

