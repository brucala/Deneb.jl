using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/unemployment-across-industries.json")
chart = data * Mark(:area) * Encoding(
    x=field("yearmonth(date)", axis=(;format="%Y")),
    y=field("sum(count)", title=:count),
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
