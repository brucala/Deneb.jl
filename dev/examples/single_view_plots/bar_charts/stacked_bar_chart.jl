using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

chart = data * Mark(:bar) * Encoding(
    x=:variety,
    y="sum(yield)",
    color=:site,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
