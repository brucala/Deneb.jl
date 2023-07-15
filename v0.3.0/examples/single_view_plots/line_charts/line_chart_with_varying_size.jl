using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:trail) * Encoding(
    "date:T",
    "price:Q",
    size="price:Q",
    color=:symbol,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

