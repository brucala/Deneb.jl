# ---
# cover: assets/radial_plot.png
# author: bruno
# description: radial plot
# ---

using Deneb

data = (;
    values=[12, 23, 47, 6, 52, 19]
)
chart = Data(data) * Mark(:arc, innerRadius=25) * Encoding(
    theta="data:q",
    radius=field("data:q", scale=(type=:sqrt, zero=true, rangeMin=20)),
    color=field("data:n", legend=nothing),
)

# save cover #src
save("assets/radial_plot.png", chart) #src
