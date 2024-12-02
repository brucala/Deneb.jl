using Deneb, Graphs, NetworkLayout

g = smallgraph(:petersen)

chart = plotgraph(g, layout=Shell(nlist=[6:10, ]))

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
