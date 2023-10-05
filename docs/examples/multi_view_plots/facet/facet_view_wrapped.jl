# ---
# cover: assets/wrapped_facet_view.png
# author: bruno
# description: Facet View (wrapped)
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

chart = Data(data) * Mark(:point) * Facet(
    "MPAA Rating", type=:ordinal, columns=3
) * Encoding(
    x=field("Worldwide Gross:Q"),
    y="US DVD Sales:Q",
)

# save cover #src
save("assets/wrapped_facet_view.png", chart) #src

# ## `facet` as encoding channel

chart = Data(data) * Mark(:point) * Encoding(
    x=field("Worldwide Gross:Q"),
    y="US DVD Sales:Q",
    facet=field("MPAA Rating", type=:ordinal, columns=3),
)
