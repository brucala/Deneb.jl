# ---
# cover: assets/line_chart_with_monotone_interpolation.png
# author: bruno
# description: Line Chart with Monotone Interpolation
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:line, interpolate="monotone") * Encoding(
    "yearquarter(date):T",
    "sum(price):Q",
)

save("assets/line_chart_with_monotone_interpolation.png", chart)  #src
