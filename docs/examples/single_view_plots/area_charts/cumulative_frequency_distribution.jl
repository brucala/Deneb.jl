# ---
# cover: assets/cumulative_distribution.png
# author: bruno
# description: Cumulative Frequency Distribution
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

chart = Data(data) * Mark(:area) * transform_window(
    Cumulative_Count="count(count)",
    sortby="IMDB Rating",
    frame=(nothing, 0),
) * Encoding(
    "IMDB Rating:Q",
    "Cumulative_Count:Q"
)

# save cover #src
save("assets/cumulative_distribution.png", chart) #src
