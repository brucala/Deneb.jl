# ---
# cover: assets/earthquakes.png
# author: bruno
# description: Earthquakes
# ---

using Deneb

sphere = Data(:sphere) * Mark(:geoshape, fill=:aliceblue)

world = Data(
    url="https://vega.github.io/vega-datasets/data/world-110m.json",
    format=(type=:topojson, feature=:countries),
) * Mark(:geoshape, fill=:mintcream, stroke=:black,)

earthquakes = Data(
    url="https://vega.github.io/vega-datasets/data/earthquakes.json",
    format=(type=:json, property=:features),
) * transform_calculate(
    longitude="datum.geometry.coordinates[0]",
    latitude="datum.geometry.coordinates[1]",
    magnitude="datum.properties.mag",
) * transform_filter(
    "(rotate0 * -1) - 90 < datum.longitude && datum.longitude < (rotate0 * -1) + 90 && (rotate1 * -1) - 90 < datum.latitude && datum.latitude < (rotate1 * -1) + 90"
) * Mark(
    :circle, color=:red, opacity=0.25,
) * Encoding(
    longitude=:longitude,
    latitude=:latitude,
    size=field(
        :magnitude,
        scale=(
            type=:sqrt,
            domain=[0, 100],
            range=[0, (; expr="pow(earthquakeSize, 3)")],
        ),
        legend=nothing,
    ),
    tooltip=:magnitude
)

chart = select_range(
    :rotate0, value=0, min=-90, max=90, step=1,
) * select_range(
    :rotate1, value=0, min=-90, max=90, step=1,
) * select_range(
    :earthquakeSize, value=6, min=0, max=12, step=0.1,
) * projection(
    :orthographic, rotate=(; expr="[rotate0, rotate1, 0]")
) * (sphere + world + earthquakes)

# save cover #src
save("assets/earthquakes.png", chart) #src
