using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:point) * transform_calculate(
    url="'https://www.google.com/search?q=' + datum.Name",
) * Encoding(
    "Horsepower:Q",
    "Miles_per_Gallon:Q",
    color=:Origin,
    tooltip=:Name,
    href=:url,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

