# ---
# cover: assets/scatter_plot.png
# author: bruno
# description: Simple Scatter Plot
# ---

using Deneb
chart = Data(
    url="https://vega.github.io/vega-datasets/data/cars.json"
) * Mark(
    :point, tooltip=true
) * Encoding(
    "Horsepower:q",
    "Miles_per_Gallon:q",
    color=:Origin
)

# save cover #src
save("assets/scatter_plot.png", chart) #src
