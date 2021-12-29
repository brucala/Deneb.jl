# ---
# cover: assets/bubble_plot.png
# author: bruno
# description: Bubble Plot
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")
chart = Data(data) * Mark(:point) * Encoding(
    x="Horsepower:Q",
    y="Miles_per_Gallon:Q",
    size="Acceleration:Q",
)

# save cover #src
save("assets/bubble_plot.png", chart) #src
