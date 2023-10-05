# ---
# cover: assets/repeated_line_charts.png
# author: bruno
# description: Repeated Line Charts
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/weather.csv")

chart = Data(data) * Mark(:line) * Repeat(
    column = ["temp_max", "precipitation", "wind"]
) * Encoding(
    x="month(date)",
    y=(field=(;repeat=:column), aggregate=:mean),
    color=:location,
)

# save cover #src
save("assets/repeated_line_charts.png", chart) #src
