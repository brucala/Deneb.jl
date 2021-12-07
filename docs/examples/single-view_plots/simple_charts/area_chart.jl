# ---
# cover: assets/area_chart.png
# author: bruno
# description: Simple Stacked Area Chart
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/iowa-electricity.csv")
chart = data * Mark(:area, tooltip=true) * Encoding(
    "year:t",
    "net_generation:q",
    color=field("source:n")
)

# save cover #src
save("assets/area_chart.png", chart) #src
