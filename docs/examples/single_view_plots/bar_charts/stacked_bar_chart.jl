# ---
# cover: assets/stacked_bar_chart.png
# author: bruno
# description: Stacked Bar Chart
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

chart = data * Mark(:bar) * Encoding(
    x=:variety,
    y="sum(yield)",
    color=:site,
)

save("assets/stacked_bar_chart.png", chart)  #src
