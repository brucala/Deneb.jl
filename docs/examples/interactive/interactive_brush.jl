# ---
# cover: assets/interactive_brush.png
# author: bruno
# description: Interactive Rectangular Brush
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:point) * select_interval(
    :brush,
    value=(x=[55, 160], y=[13, 37]),
) * Encoding(
    "Horsepower:Q",
    "Miles_per_Gallon:Q",
    color=condition(:brush, field("Cylinders:O"), "grey"),
)

# save cover #src
save("assets/interactive_brush.png", chart) #src
