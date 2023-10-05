# ---
# cover: assets/normalized_area_chart.png
# author: bruno
# description: Normalized Area Chart
# generate_cover: true
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/iowa-electricity.csv")
chart = data * Mark(:area) * Encoding(
    "year:t",
    y=field("net_generation:q", stack="normalize", axis=(;format="%")),
    color="source:n"
)

# save cover #src
save("assets/normalized_area_chart.png", chart) #src
