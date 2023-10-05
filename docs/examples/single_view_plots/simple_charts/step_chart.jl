# ---
# cover: assets/step_chart.png
# author: bruno
# description: Simple Step Chart
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/stocks.csv")

chart = data * Mark(:line, interpolate="step-after") * Encoding(
    "yearquarter(date):T",
    "sum(price):Q",
)

save("assets/step_chart.png", chart)  #src
