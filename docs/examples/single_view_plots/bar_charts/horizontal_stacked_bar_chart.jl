# ---
# cover: assets/horizontal_stacked_bar_chart.png
# author: bruno
# description: Horizontal Stacked Bar Chart
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

chart = data * Mark(:bar) * Encoding(
    "sum(yield)",
    :variety,
    color=:site,
)

save("assets/horizontal_stacked_bar_chart.png", chart)  #src
