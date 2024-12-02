using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:line, interpolate="monotone") * Encoding(
    "yearquarter(date):T",
    "sum(price):Q",
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
