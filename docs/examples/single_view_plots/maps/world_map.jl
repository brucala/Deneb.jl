# ---
# cover: assets/world_map.png
# author: bruno
# description: World Map
# ---

using Deneb

## Background using VegaLite's sphere and graticule generators
sphere = Data(:sphere) * Mark(:geoshape, fill=:lightblue)
graticule = Data(:graticule, step=[20, 20]) * Mark(:geoshape, stroke=:gray, strokeWidth=0.5)

countries = Data(
    url="https://vega.github.io/vega-datasets/data/world-110m.json",
    format=(type=:topojson, feature=:countries),
) * Mark(:geoshape, fill=:forestgreen, stroke=:black,)

chart = (sphere + graticule + countries) * vlspec(
    width=600, height=400
) * projection(:NaturalEarth1) * config(:view, stroke="")

# save cover #src
save("assets/world_map.png", chart) #src
