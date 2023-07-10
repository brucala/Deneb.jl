using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

config_options = vlspec(
    height=50,
    width=350
) * config(:axis, grid=false)

chart = Data(data) * Mark(:area) * Facet(row=:symbol) * transform_filter(
    "datum.symbol !== 'GOOG'"
) * Encoding(
    x="date:t",
    y="price:q",
    color=:symbol,
) * config_options

chart = Data(data) * Mark(:area) * transform_filter(
    "datum.symbol !== 'GOOG'"
) * Encoding(
    x="date:t",
    y="price:q",
    color=:symbol,
    row=:symbol,
) * config_options

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

