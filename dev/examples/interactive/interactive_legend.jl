using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/unemployment-across-industries.json")

chart = data * Mark(:area) * Encoding(
    "yearmonth(date):T",
    y=field("sum(count)", stack="center", axis=nothing),
    color=field("series", scale=(;scheme=:category20b)),
    opacity=condition(:select_legend, 1, 0.2),
) * select_legend(:select_legend)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
