# ---
# cover: assets/line_chart_with_log_scale.png
# author: bruno
# description: Line Chart with Log Scale
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/population.json")

chart = data * Mark(:line) * Encoding(
    "year:O",
    y=field("sum(people)", scale=(;type=:log)),
)

save("assets/line_chart_with_log_scale.png", chart)  #src
