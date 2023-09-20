using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:circle) * select_dropdown(
    :x;
    value=:Horsepower,
    options=[:Horsepower, :Displacement, :Weight_in_lbs, :Acceleration, :Miles_per_Gallon],
    name="X-axis",
) * select_dropdown(
    :y;
    value=:Miles_per_Gallon,
    options=[:Horsepower, :Displacement, :Weight_in_lbs, :Acceleration, :Miles_per_Gallon],
    name="Y-axis"
) * transform_calculate(
    x="datum[x]",
    y="datum[y]",
) * Encoding(
    x=field("x:Q", axis=(; title=expr(:x))),
    y=field("y:Q", axis=(; title=expr(:y))),
    color="Origin:N",
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
