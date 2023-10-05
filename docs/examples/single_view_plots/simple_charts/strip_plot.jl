# ---
# cover: assets/strip_plot.png
# author: bruno
# description: Simple Strip Plot
# generate_cover: true
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")
chart = data * Mark(:tick) * Encoding(
    "Horsepower:q",
    "Cylinders:o",
)

# save cover #src
save("assets/strip_plot.png", chart) #src
