# ---
# cover: assets/2d_histogram_heatmap.png
# author: bruno
# description: 2D Histogram Heatmap
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")
chart = Data(data) * Mark(:rect, tooltip=true) * Encoding(
    x=field("IMDB Rating", bin=(;maxbins=40)),
    y=field("Rotten Tomatoes Rating", bin=(;maxbins=40)),
    color="count()"
)

# save cover #src
save("assets/2d_histogram_heatmap.png", chart) #src
