using Deneb
data = Data(url="https://cdn.jsdelivr.net/npm/vega-datasets@v1.29.0/data/iris.json")
chart = Data(data) * Mark(:circle) * Encoding(
    x=field("sepalLength:Q", scale=(;zero=false)),
    y=field("sepalWidth:Q", scale=(;zero=false, padding=1)),
    color="species",
    size="petalWidth:Q",
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
