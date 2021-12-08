# ---
# cover: assets/line_chart_with_point_markers.png
# author: bruno
# description: Line Chart with point markers
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:line, point=true) * Encoding(
    "year(date):T",
    "mean(price):Q",
    color=:symbol,
)

save("assets/line_chart_with_point_markers.png", chart)  #src
