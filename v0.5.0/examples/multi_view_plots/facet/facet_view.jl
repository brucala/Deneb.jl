using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = Data(data) * Mark(:bar) * Facet(column=:Origin) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()"
) * vlspec(
    height=200, width=200
)

chart = Data(data) * Mark(:bar) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()",
    column=:Origin,
) * vlspec(
    height=200, width=200
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
