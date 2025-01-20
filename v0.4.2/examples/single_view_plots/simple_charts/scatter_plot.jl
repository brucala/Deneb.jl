using Deneb
cars = "https://vega.github.io/vega-datasets/data/cars.json"
chart = Data(url=cars) * Mark(:point) * Encoding(
    "Horsepower:q",
    "Miles_per_Gallon:q",
    color=:Origin
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
