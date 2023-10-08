# ---
# cover: assets/connected_scatter_plot.png
# author: bruno
# description: Connected Scatter Plot
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/driving.json")

chart = data * Mark(:line, point=true) * Encoding(
    x=field("miles:Q", scale=(;zero=false)),
    y=field("gas:Q", scale=(;zero=false)),
    order=:year
)

save("assets/connected_scatter_plot.png", chart)  #src
