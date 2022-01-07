# ---
# cover: assets/boxplot.png
# author: bruno
# description: Box Plot (1.5 IQR)
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")

chart = data * Mark(:boxplot) * Encoding(
    x=:Species,
    y=(field="Body Mass (g)", type=:quantitative, scale=(;zero=false)),
    color=field(:Species, legend=nothing)
)

save("assets/error_bars_stdev.png", chart)  #src
