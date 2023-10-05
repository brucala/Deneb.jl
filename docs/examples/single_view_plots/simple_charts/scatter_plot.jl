# ---
# cover: assets/scatter_plot.png
# author: bruno
# description: Simple Scatter Plot
# generate_cover: true
# ---

using Deneb
cars = "https://vega.github.io/vega-datasets/data/cars.json"
chart = Data(url=cars) * Mark(:point) * Encoding(
    "Horsepower:q",
    "Miles_per_Gallon:q",
    color=:Origin
)

# save cover #src
save("assets/scatter_plot.png", chart) #src
