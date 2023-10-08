# ---
# cover: assets/streamgraph.png
# author: bruno
# description: Streamgraph
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/unemployment-across-industries.json")
chart = data * Mark(:area) * Encoding(
    "yearmonth(date):T",
    y=field("sum(count)", stack="center", axis=nothing),
    color=field("series", scale=(;scheme=:category20b))
)

# save cover #src
save("assets/streamgraph.png", chart) #src
