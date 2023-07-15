using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/iowa-electricity.csv")
chart = data * Mark(:area) * Encoding(
    "year:t",
    "net_generation:q",
    color="source:n"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

