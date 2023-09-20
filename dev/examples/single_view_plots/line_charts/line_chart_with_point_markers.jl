using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:line, point=true) * Encoding(
    "year(date):T",
    "mean(price):Q",
    color=:symbol,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
