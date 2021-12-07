# ---
# cover: assets/line_chart.png
# author: bruno
# description: Simple Line Chart
# ---

using Deneb
x=0:0.2:25
y=sin.(x)
chart = Data((;x, y)) * Mark(:line) * Encoding("x:q", "y:q")

# save cover #src
save("assets/line_chart.png", chart) #src
