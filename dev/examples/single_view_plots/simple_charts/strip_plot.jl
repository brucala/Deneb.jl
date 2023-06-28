using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")
chart = data * Mark(:tick) * Encoding(
    "Horsepower:q",
    "Cylinders:o",
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

