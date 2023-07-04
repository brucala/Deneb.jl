using Deneb

usa = Data(
    url="https://vega.github.io/vega-datasets/data/us-10m.json",
    format=(type=:topojson, feature=:states),
)
flights = Data(url="https://vega.github.io/vega-datasets/data/flights-airport.csv")
airports = (
    data=(; url="https://vega.github.io/vega-datasets/data/airports.csv"),
    key=:iata,
    fields=[:state, :latitude, :longitude],
)


base = projection("albersUsa") * vlspec(width=750, height=500)

background = usa * Mark(
    :geoshape, fill=:lightgray, stroke=:white
)

connections = flights * Mark(:rule, opacity=0.35) * transform_filter(
    (param=:org, empty=false),
) * transform_lookup(
    :origin, airports,
) *  transform_lookup(
    :destination, airports; as=[:state, :lat2, :lon2],
) * Encoding(
    longitude=:longitude,
    latitude=:latitude,
    longitude2=:lon2,
    latitude2=:lat2,
)

points = flights * Mark(:circle) * select_point(
    :org, on=:mouseover, nearest=true, fields=[:origin], empty=false,
) * transform_aggregate(
    routes="count()",
    groupby=:origin,
) * transform_lookup(
    :origin, airports,
) * transform_filter(
    "datum.state !== 'PR' && datum.state !== 'VI'"
)* Encoding(
    longitude=:longitude,
    latitude=:latitude,
    size=field("routes:Q", scale=(; range=[0, 1000]), legend=nothing),
    order=field("routes:Q", sort="descending"),
    tooltip=[field("origin:N"), field("routes:Q")],
)


chart = base * (background + connections + points)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

