# ---
# cover: assets/bar_chart.png
# author: bruno
# description: Simple Bar Chart
# ---

using Deneb
data = (a=string.('A':'I'), b=rand(0:100, 9))
chart = Data(data) * Mark(:bar, tooltip=true) * Encoding("a:n", "b:q")

# save cover #src
save("assets/bar_chart.png", chart) #src
