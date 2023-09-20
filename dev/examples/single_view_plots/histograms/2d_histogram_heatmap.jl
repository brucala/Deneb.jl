using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")
chart = Data(data) * Mark(:rect) * Encoding(
    x=field("IMDB Rating", bin=(;maxbins=40)),
    y=field("Rotten Tomatoes Rating", bin=(;maxbins=40)),
    color="count()"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
