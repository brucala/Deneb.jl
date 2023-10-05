# ---
# cover: assets/line_chart_with_varying_size.png
# author: bruno
# description: Line Chart with Varying Size
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:trail) * Encoding(
    "date:T",
    "price:Q",
    size="price:Q",
    color=:symbol,
)

save("assets/line_chart_with_varying_size.png", chart)  #src
