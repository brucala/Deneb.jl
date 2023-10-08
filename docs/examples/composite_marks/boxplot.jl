# ---
# cover: assets/boxplot.png
# author: bruno
# description: Box Plot (1.5 IQR)
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")

chart = data * Mark(:boxplot, size=30) * Encoding(
    y=(field="Body Mass (g)", type=:quantitative, scale=(;zero=false)),
    x=:Species,
    color=field(:Species, legend=nothing)
) * vlspec(width=250, height=250)

save("assets/boxplot.png", chart)  #src
