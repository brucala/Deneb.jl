# ---
# cover: assets/pie_chart.png
# author: bruno
# description: Pie Chart
# ---

using Deneb

data = (
    category=1:6,
    value=rand(1:10, 6)
)
chart = Data(data) * Mark(:arc) * Encoding(
    theta="value:q",
    color="category:n"
)

# save cover #src
save("assets/pie_chart.png", chart) #src
