using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/weather.csv")

chart = Data(data) * Mark(:line) * Repeat(
    column = ["temp_max", "precipitation", "wind"]
) * Encoding(
    x="month(date)",
    y=(field=(;repeat=:column), aggregate=:mean),
    color=:location,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

