using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv")

bar = Mark(:bar) * select_interval(
    :brush,
    encodings=[:x],
) * Encoding(
    "month(date):O",
    "mean(precipitation)",
    opacity=condition(:brush, 1, 0.7),
)

rule = Mark(:rule, color=:firebrick, size=3) * transform_filter(
    param(:brush)
) * Encoding(y="mean(precipitation)")

chart = data * (bar + rule)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

