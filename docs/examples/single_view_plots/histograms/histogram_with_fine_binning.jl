# ---
# cover: assets/histogram_fine_binning.png
# author: bruno
# description: Histogram with Fine Binning
# generate_cover: true
# ---

using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")
chart = Data(data) * Mark(:bar) * Encoding(
    x=field("IMDB Rating", bin=(;maxbins=50)),
    y="count()"
)

# save cover #src
save("assets/histogram_fine_binning.png", chart) #src
