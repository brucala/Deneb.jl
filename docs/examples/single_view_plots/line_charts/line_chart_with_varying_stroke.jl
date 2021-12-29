# ---
# cover: assets/line_chart_with_varying_stroke.png
# author: bruno
# description: Line Chart with Varying stroke
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:line) * Encoding(
    "date:T",
    "price:Q",
    strokeDash=:symbol,
    color=:symbol,
)

save("assets/line_chart_with_varying_stroke.png", chart)  #src
