using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv")

chart = data * Mark(
    :bar,
    cornerRadiusTopLeft=3,
    cornerRadiusTopRight=3
) * Encoding(
    "month(date):O",
    "count():Q",
    color="weather:N",
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
