# ---
# cover: assets/wrapped_facet_view.png
# author: bruno
# description: Facet View (wrapped)
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = Data(data) * Mark(:bar) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()"
) * vlspec(
    height=200, width=200
)

# save cover #src
save("assets/wrapped_facet_view.png", chart) #src

# Using `facet` as an encoding channel:

chart = Data(data) * Mark(:bar) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()",
    facet=field(:Origin, columns=2),
) * vlspec(
    height=200, width=200
)
