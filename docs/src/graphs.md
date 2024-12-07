# Graphs extensions

!!! note "
    This is work in progress


If `Graphs` and `NetworLayout` are installed the `GraphsExt` extension is automatically loaded.
This extension allows to conveniently draw network charts from any `AbstractGraph` using a given
layout from `NetworLayout` (Spring layout by default).

```@example
using Deneb, Graphs, NetworkLayout

g = barabasi_albert(25, 1)

chart = plotgraph(
    g,
    node_labels=true,  # graph id (could've been a vector or an attribute)
    node_colors=:state,  # assigns a node attribute named 'state' to be used as node color encoding
    node_state=rand("abcde", nv(g)),  # defines the nodes attribute named 'state'
    node_sizes=rand(nv(g)),  # directly uses a vector as the size encoding
    node_shapes=:active,  # assigns attribute active to shape encoding
    node_active=rand(Bool, nv(g)), # defines 'active' attribute of a node
    edge_colors=rand(["blue", "orange", "red"], ne(g)),  # vector to be used as edge color encoding
    edge_widths=:width,  # an edge attribute as edge strokeWidth encoding
    edge_width_type=:q,  # Deneb's shorthand for quantitative
    edge_dashes=:state,  # another edge attribute
    edge_state=rand((:on, :off), ne(g)),  # the edges' state attribute
    edge_width=rand(1:50, ne(g)),  # the edges' width attribute
) * vlspec(height=500, width=500)
```

more to be said...