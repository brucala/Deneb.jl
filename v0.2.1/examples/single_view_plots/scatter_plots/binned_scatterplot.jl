using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")
chart = Data(data) * Mark(:circle) * Encoding(
    x=field("IMDB Rating", bin=true),
    y=field("Rotten Tomatoes Rating", bin=true),
    size="count()"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

