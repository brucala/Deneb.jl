# ---
# cover: assets/cumulative_distribution.png
# author: bruno
# description: Cumulative Frequency Distribution
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

chart = Data(data) * Mark(:area) * Transform(
    sort=[(;field="IMDB Rating")],
    window=[(op=:count, field=:count, as="Cumulative Count")],
    frame=[nothing, 0]
) * Encoding(
    "IMDB Rating:Q",
    "Cumulative Count:Q"
)

# save cover #src
save("assets/cumulative_distribution.png", chart) #src
