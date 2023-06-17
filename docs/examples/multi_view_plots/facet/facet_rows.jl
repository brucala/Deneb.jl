# ---
# cover: assets/facet_rows.png
# author: bruno
# description: Facet Area (rows)
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

config = vlspec(
    height=50,
    width=350,
    config=(;axis=(;grid=false)),
)

chart = Data(data) * Mark(:area) * Facet(row=:symbol) * transform_filter(
    "datum.symbol !== 'GOOG'"
) * Encoding(
    x="date:t",
    y="price:q",
    color=:symbol,
) * config

# save cover #src
save("assets/facet_rows.png", chart) #src

# ## `row` as an encoding channel:

chart = Data(data) * Mark(:area) * transform_filter(
    "datum.symbol !== 'GOOG'"
) * Encoding(
    x="date:t",
    y="price:q",
    color=:symbol,
    row=:symbol,
) * config
