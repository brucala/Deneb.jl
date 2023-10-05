# ---
# cover: assets/normalized_bar_chart.png
# author: bruno
# description: Normalized Bar Chart
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

chart = data * Mark(:bar) * Encoding(
    x=field("sum(yield)", stack=:normalize),
    y=:variety,
    color=:site,
)

save("assets/normalized_bar_chart.png", chart)  #src
