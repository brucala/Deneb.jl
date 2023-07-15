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

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

