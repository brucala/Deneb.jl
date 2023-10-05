# ---
# cover: assets/2d_histogram_scatterplot.png
# author: bruno
# description: 2D Histogram Scatterplot
# generate_cover: true
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")
chart = Data(data) * Mark(:circle) * Encoding(
    x=field("IMDB Rating", bin=true),
    y=field("Rotten Tomatoes Rating", bin=true),
    size="count()"
)

# save cover #src
save("assets/2d_histogram_scatterplot.png", chart) #src
