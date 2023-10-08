# ---
# cover: assets/sorted_bar_chart.png
# author: bruno
# description: Sorted Bar Chart
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

chart = data * Mark(:bar) * Encoding(
    x="sum(yield):Q",
    y=field("site:N", sort="-x"),
)

save("assets/sorted_bar_chart.png", chart)  #src
