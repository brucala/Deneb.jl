using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")

chart = data * Mark(:boxplot, size=30) * Encoding(
    y=(field="Body Mass (g)", type=:quantitative, scale=(;zero=false)),
    x=:Species,
    color=field(:Species, legend=nothing)
) * vlspec(width=250, height=250)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

