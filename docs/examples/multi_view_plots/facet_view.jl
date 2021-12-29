# ---
# cover: assets/facet_view.png
# author: bruno
# description: Facet View
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = Data(data) * Mark(:bar) * Facet(column=:Origin) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()"
) * vlspec(
    height=200, width=200
)

# save cover #src
save("assets/facet_view.png", chart) #src

# Using `column` as an encoding channel:

chart = Data(data) * Mark(:bar) * Encoding(
    x=field("Horsepower:Q", bin=(;maxbins=15)),
    y="count()",
    column=:Origin,
) * vlspec(
    height=200, width=200
)
