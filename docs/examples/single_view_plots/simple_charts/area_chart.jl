# ---
# cover: assets/area_chart.png
# author: bruno
# description: Simple Area Chart
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/unemployment-across-industries.json")
chart = data * Mark(:area) * Encoding(
    x=field("yearmonth(date)", axis=(;format="%Y")),
    y=field("sum(count)", title=:count),
)

# save cover #src
save("assets/area_chart.png", chart) #src
