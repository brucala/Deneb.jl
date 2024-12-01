# ---
# cover: assets/graph_chart_layout.png
# author: bruno
# description: Graph Chart wih Custom Layout
# ---

using Deneb, Graphs, NetworkLayout

g = smallgraph(:petersen)

chart = plotgraph(g, layout=Shell(nlist=[6:10, ]))

# save cover #src
save("assets/graph_chart_layout.png", chart) #src
