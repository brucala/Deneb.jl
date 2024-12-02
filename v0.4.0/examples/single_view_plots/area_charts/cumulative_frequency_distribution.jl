using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

chart = Data(data) * Mark(:area) * transform_aggregate(
    count="count()", groupby="IMDB Rating",
) * transform_window(
    Cumulative_Count="sum(count)",
    sortby="IMDB Rating",
    frame=(nothing, 0),
) * Encoding(
    "IMDB Rating:Q",
    "Cumulative_Count:Q"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
