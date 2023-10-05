# ---
# cover: assets/donut_chart.png
# author: bruno
# description: Donut Chart
# generate_cover: true
# ---

using Deneb

data = (
    category=1:6,
    value=rand(1:10, 6)
)
chart = Data(data) * Mark(:arc, innerRadius=75) * Encoding(
    theta="value:q",
    color="category:n"
)

# save cover #src
save("assets/donut_chart.png", chart) #src
