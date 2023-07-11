using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

chart = Data(data) * Mark(:point, invalid=nothing) * Encoding(
    "IMDB Rating:Q",
    "Rotten Tomatoes Rating:Q",
    color=condition_test(
        "datum['IMDB Rating'] === null || datum['Rotten Tomatoes Rating'] === null",
        "#aaa"
    )
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

