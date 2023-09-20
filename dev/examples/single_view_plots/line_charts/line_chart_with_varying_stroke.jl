using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:line) * Encoding(
    "date:T",
    "price:Q",
    strokeDash=:symbol,
    color=:symbol,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
