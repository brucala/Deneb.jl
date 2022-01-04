# ---
# cover: assets/bar_chart.png
# author: bruno
# description: Simple Bar Chart
# ---

using Deneb
data = (a=string.('A':'L'), b=rand(0:100, 12))
chart = Data(data) * Mark(:bar) * Encoding("a:n", "b:q")

# save cover #src
save("assets/bar_chart.png", chart) #src
