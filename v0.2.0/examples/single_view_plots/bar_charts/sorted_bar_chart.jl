using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

chart = data * Mark(:bar) * Encoding(
    x="sum(yield):Q",
    y=field("site:N", sort="-x"),
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

