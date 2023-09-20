using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/population.json")

chart = data * Mark(:line) * Encoding(
    "year:O",
    y=field("sum(people)", scale=(;type=:log)),
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
