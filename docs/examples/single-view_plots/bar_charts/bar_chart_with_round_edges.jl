# ---
# cover: assets/bar_chart_with_round_edges.png
# author: bruno
# description: Bar Chart with Round Edges
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv")

chart = data * Mark(
    :bar,
    cornerRadiusTopLeft=3,
    cornerRadiusTopRight=3
) * Encoding(
    "month(date):O",
    "count():Q",
    color=field("weather:N")
)

save("assets/bar_chart_with_round_edges.png", chart)  #src
