# ---
# cover: assets/graph_chart.png
# author: bruno
# description: Simple Graph Chart
# ---

using Deneb, Graphs, NetworkLayout

g = wheel_graph(10)

chart = plotgraph(g)

# save cover #src
save("assets/graph_chart.png", chart) #src
