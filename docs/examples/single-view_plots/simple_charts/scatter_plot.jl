# ---
# cover: assets/scatter_plot.png
# author: bruno
# description: Simple Scatter Plot
# ---

using Deneb
chart = Data(url="data/cars.json") * Mark(:line, tooltip=true) * Encoding(
    "Horsepower:q",
    "Miles_per_Gallon:q",
    color=(;field=:Origin)
)

# save cover #src
save("assets/scatter_plot.png", chart) #src
