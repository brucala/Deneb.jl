# ---
# cover: assets/stacked_density.png
# author: bruno
# description: Stacked Density Estimates
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")

chart = Data(data) * Mark(:area) * Transform(
    density="Body Mass (g)",
    groupby=["Species"],
    extent=[2500, 6500]
) * Encoding(
    x=field("value:q", title="Body Mass (g)"),
    y=field("density:q", stack="zero"),
    color=:Species
) * vlspec(
    width = 500, height=200
)

# save cover #src
save("assets/stacked_density.png", chart) #src
