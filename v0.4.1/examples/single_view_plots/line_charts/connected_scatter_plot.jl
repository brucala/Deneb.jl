using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/driving.json")

chart = data * Mark(:line, point=true) * Encoding(
    x=field("miles:Q", scale=(;zero=false)),
    y=field("gas:Q", scale=(;zero=false)),
    order=:year
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
