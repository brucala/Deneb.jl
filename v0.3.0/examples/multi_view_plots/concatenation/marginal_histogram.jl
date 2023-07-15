using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

top_hist = Mark(:bar) * Encoding(
    x=field("IMDB Rating", bin=true, axis=nothing),
    y=field("count()", title=""),
) * vlspec(height=60)

right_hist = Mark(:bar) * Encoding(
    y=field("Rotten Tomatoes Rating", bin=true, axis=nothing),
    x=field("count()", title=""),
) * vlspec(width=60)

hist2d = Mark(:rect) * Encoding(
    x=field("IMDB Rating", bin=true),
    y=field("Rotten Tomatoes Rating", bin=true),
    color="count()",
)

chart = data * [top_hist; [hist2d right_hist]]

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

