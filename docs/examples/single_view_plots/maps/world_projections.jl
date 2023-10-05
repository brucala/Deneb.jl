# ---
# cover: assets/maps_world_projections.png
# author: bruno
# description: World Projections
# generate_cover: true
# ---

using Deneb

data = Data(
    url="https://vega.github.io/vega-datasets/data/world-110m.json",
    format=(type=:topojson, feature=:countries),
)

base = data * Mark(:geoshape, fill=:lightgray, stroke=:gray) * vlspec(
    width=300, height=180
)

projections = ["equirectangular", "mercator", "orthographic", "gnomonic"]

chart = base * concat((projection(proj) * vlspec(title=proj) for proj in projections)..., columns=2)

# save cover #src
save("assets/maps_world_projections.png", chart) #src
