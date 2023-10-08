# ---
# cover: assets/scatter_null_in_gray.png
# author: bruno
# description: Scatterplot with Nulls in Gray
# ---

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

# save cover #src
save("assets/scatter_null_in_gray.png", chart) #src
