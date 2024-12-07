# ---
# cover: assets/graph_chart_labels.png
# author: bruno
# description: Graph Chart wih Custom Labels
# ---

using Deneb, Graphs, NetworkLayout

g = smallgraph(:cubical)

chart = plotgraph(g, node_labels='a':'h', edge_labels=1:12)

# save cover #src
save("assets/graph_chart_labels.png", chart) #src
