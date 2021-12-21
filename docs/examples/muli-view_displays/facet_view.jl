# ---
# cover: assets/facet_view.png
# author: bruno
# description: Facet View
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = Data(data) * Mark(:bar) * Facet(:Origin, columns=2) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()"
)

# save cover #src
save("assets/facet_view.png", chart) #src
