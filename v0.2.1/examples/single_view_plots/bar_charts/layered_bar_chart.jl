using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/iowa-electricity.csv")

chart = data * Mark(:bar, opacity=0.7) * Encoding(
    "year:O",
    y=field("net_generation:Q", stack=nothing),
    color=:source,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

