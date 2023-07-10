using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/population.json")

chart = data * Mark(:bar) * transform_filter(
    "datum.year == 2000"
)* Encoding(
    x=field("sum(people)", title=:population),
    y="age",
) * vlspec(height=(;step=18))

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

