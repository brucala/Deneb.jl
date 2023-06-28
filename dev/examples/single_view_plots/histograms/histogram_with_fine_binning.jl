using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")
chart = Data(data) * Mark(:bar) * Encoding(
    x=field("IMDB Rating", bin=(;maxbins=50)),
    y="count()"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

