# ---
# cover: assets/layered_bar_chart.png
# author: bruno
# description: Layered Bar Chart
# generate_cover: true
# ---


using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/iowa-electricity.csv")

chart = data * Mark(:bar, opacity=0.7) * Encoding(
    "year:O",
    y=field("net_generation:Q", stack=nothing),
    color=:source,
)

save("assets/layered_bar_chart.png", chart)  #src
