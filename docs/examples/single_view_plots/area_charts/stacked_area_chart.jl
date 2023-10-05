# ---
# cover: assets/stacked_area_chart.png
# author: bruno
# description: Simple Stacked Area Chart
# generate_cover: true
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/iowa-electricity.csv")
chart = data * Mark(:area) * Encoding(
    "year:t",
    "net_generation:q",
    color="source:n"
)

# save cover #src
save("assets/stacked_area_chart.png", chart) #src
