# ---
# cover: assets/scatterplot_colors_shapes.png
# author: bruno
# description: Scatterplot with Colors and Shapes
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")
chart = Data(data) * Mark(:point) * Encoding(
    x=(field="Flipper Length (mm)", type=:quantitative, scale=(;zero=false)),
    y=(field="Body Mass (g)", type=:quantitative, scale=(;zero=false)),
    color=:Species,
    shape=:Species,
)

# save cover #src
save("assets/scatterplot_colors_shapes.png", chart) #src
