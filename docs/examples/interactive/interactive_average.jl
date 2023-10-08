# ---
# cover: assets/interactive_average.png
# author: bruno
# description: Interactive Average
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv")

bar = Mark(:bar) * select_interval(
    :brush,
    encodings=[:x],
) * Encoding(
    "month(date):O",
    "mean(precipitation)",
    opacity=condition(:brush, 1, 0.7),
)

rule = Mark(:rule, color=:firebrick, size=3) * transform_filter(
    param(:brush)
) * Encoding(y="mean(precipitation)")

chart = data * (bar + rule)

# save cover #src
save("assets/interactive_average.png", chart) #src
