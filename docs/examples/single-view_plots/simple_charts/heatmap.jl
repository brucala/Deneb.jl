# ---
# cover: assets/heatmap.png
# author: bruno
# description: Simple Heatmap
# ---

using Deneb
x = repeat(0:0.1:1, inner=11)
y = repeat(0:0.1:1, outer=11)
z = x.^2 .+ y.^2
chart = Data((;x, y, z)) * Mark(:rect) * Encoding(
    "x:o",
    "y:o",
    color=(field=:z, type=:quantitative)
)

# save cover #src
save("assets/heatmap.png", chart) #src
