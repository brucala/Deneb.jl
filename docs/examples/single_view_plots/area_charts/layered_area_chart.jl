# ---
# cover: assets/layered_area_chart.png
# author: bruno
# description: Layered Area Chart
# generate_cover: true
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/iowa-electricity.csv")
chart = data * Mark(:area, opacity=0.3) * Encoding(
    "year:t",
    y=field("net_generation:q", stack=nothing),
    color="source:n"
)

# save cover #src
save("assets/layered_area_chart.png", chart) #src
