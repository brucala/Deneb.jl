# ---
# cover: assets/interactive_legend.png
# author: bruno
# description: Interactive Legend
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/unemployment-across-industries.json")

chart = data * Mark(:area) * Params(
    name=:industry,
    select=(type=:point, fields=[:series]),
    bind=:legend,
) * Encoding(
    "yearmonth(date):T",
    y=field("sum(count)", stack="center", axis=nothing),
    color=field("series", scale=(;scheme=:category20b)),
    opacity=condition(:industry, 1, 0.2),
)

# save cover #src
save("assets/interactive_legend.png", chart) #src
