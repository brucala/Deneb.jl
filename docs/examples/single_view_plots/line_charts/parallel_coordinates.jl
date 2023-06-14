# ---
# cover: assets/parallel_coordinates.png
# author: bruno
# description: Parallel Coordinates
# ---

using Deneb

data = Data(url="https://cdn.jsdelivr.net/npm/vega-datasets@v1.29.0/data/iris.json")

chart = data * Mark(:line, opacity=0.5) * Transform(
    window=[(op=:count, as=:index)],
) * Transform(
    fold=[:petalLength, :petalWidth, :sepalLength, :sepalWidth]
) * Encoding(
    x=field(:key, title=""),
    y="value:Q",
    color=:species,
    detail=:index,
) * vlspec(
    width=500
)

save("assets/parallel_coordinates.png", chart)  #src
