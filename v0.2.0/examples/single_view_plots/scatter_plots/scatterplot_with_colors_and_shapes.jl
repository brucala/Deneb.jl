using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")
chart = Data(data) * Mark(:point) * Encoding(
    x=(field="Flipper Length (mm)", type=:quantitative, scale=(;zero=false)),
    y=(field="Body Mass (g)", type=:quantitative, scale=(;zero=false)),
    color=:Species,
    shape=:Species,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

