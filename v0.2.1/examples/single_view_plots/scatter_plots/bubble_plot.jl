using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")
chart = Data(data) * Mark(:point) * Encoding(
    x="Horsepower:Q",
    y="Miles_per_Gallon:Q",
    size="Acceleration:Q",
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

