using Deneb

data = Data(url="https://cdn.jsdelivr.net/npm/vega-datasets@v1.29.0/data/iris.json")

chart = data * Mark(:line, opacity=0.5) * transform_window(
    index="count()",
) * transform_fold(
    [:petalLength, :petalWidth, :sepalLength, :sepalWidth]
) * Encoding(
    x=field(:key, title=""),
    y="value:Q",
    color=:species,
    detail=:index,
) * vlspec(
    width=500
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
