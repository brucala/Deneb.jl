module GraphsExt

using Deneb, Graphs, NetworkLayout

function node_data(g::AbstractGraph, pos; attributes...)
    data = Dict(:id => collect(vertices(g)), :x => [p[1] for p in pos], :y => [p[2] for p in pos])
    for (att_name, att_val) in attributes
        if length(att_val) == nv(g)
           data[att_name] = collect(att_val)
        else
            @warn "attribute `$att_name` must have a length ($(length(att_val))) equal to number of vertices ($(nv(g))). Skipping..."
        end
    end
    return data
end

function edge_data(g::AbstractGraph, pos; attributes...)
    e = edges(g)
    s, d = src.(e), dst.(e)
    spos, dpos = pos[s], pos[d]
    data = Dict(
        :src => s, :dst => d,
        :x => [p[1] for p in spos],
        :y => [p[2] for p in spos],
        :x2 => [p[1] for p in dpos],
        :y2 => [p[2] for p in dpos],
        :label => repr.(e),  # default labels
    )
    for (att_name, att_val) in attributes
        if length(att_val) == ne(g)
           data[att_name] = collect(att_val)
        else
            @warn "attribute `$att_name` must have a length ($(length(att_val))) equal to number of edges ($(ne(g))). Skipping..."
        end
    end
    return data
end

"""
    graph_data(graph, layout; node_attribute1, node_attribute2, edge_attribute1, ...)

Returns a `nodes`, `edges` tuple with tabular data containing the nodes and edges of the given
graph. The network layout is used to populate the position of the nodes (`:x`, `:y`) and the
edges (`(:x, :y)` for the source node and `(:x2, :y2)` for the destination node). Several node
and edges attributes can be added with keyword arguments `node_*` and `edge_*` respectively.
The attributes are expected to be a vector of the same length and order as the `vertices(graph)`
and `edges(graph)` iterators.

## Example:

using Graphs, NetworkLayout

graph_data(wheel_graph(6), Spring(); node_label="abcdef", edge_width=1:10)
"""
function Deneb.graph_data(
    g::AbstractGraph,
    layout::NetworkLayout.AbstractLayout=Spring();
    attributes...
)
    pos = layout(g)
    nodes = node_data(g, pos; _filter_attributes(attributes, "node_")...)
    edges = edge_data(g, pos; _filter_attributes(attributes, "edge_")...)
    return nodes, edges
end

function _filter_attributes(pairs, prefix)
    NamedTuple(
        Symbol(string(k)[length(prefix)+1:end]) => v
        for (k,v) in pairs
        if startswith(string(k), prefix) && !isnothing(v)
    )
end

function Deneb.Datasets(
    g::AbstractGraph,
    layout::NetworkLayout.AbstractLayout=Spring();
    attributes...
)
    nodes, edges = graph_data(g, layout; attributes...)
    return Datasets(; nodes, edges)
end

function Deneb.plotgraph(
    g::AbstractGraph,
    layout::NetworkLayout.AbstractLayout=Spring();
    node_labels::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    edge_labels::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    node_colors::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    edge_colors::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    attributes...
)

    node_label, node_color, edge_label, edge_color = fill(nothing, 4)
    if node_labels isa AbstractVector
        node_label = node_labels
        node_labels = :label
    end
    if edge_labels isa AbstractVector
        edge_label = edge_labels
        edge_labels = :label
    end
    if node_colors isa AbstractVector
        node_color = node_colors
        node_colors = :color
    end
    if edge_color isa AbstractVector
        edge_color = edge_colors
        edge_colors = :color
    end

    base = Datasets(
        g, layout; node_label, node_color, edge_label, edge_color, attributes...
    ) * Encoding(
        x=field("x:q", axis=nothing),
		y=field("y:q", axis=nothing),
    ) * config(view=(; stroke=""))

    node_tooltip = isnothing(node_labels) ? :id : [field(:id), field(node_labels)]

    nodes = Mark(
		:point, size=400, fill=:lightblue, opacity=1,
	) * Encoding(tooltip=node_tooltip)

    if !isnothing(node_labels)
        nodes += Mark(:text) * Encoding(
            text=node_labels,
            tooltip=node_tooltip,
        )
    end

    edges = Mark(:rule, size=3) * Encoding(x2=:x2, y2=:y2, tooltip=:label) * interactive_scales()
    #=  needs to infer the right position
    if !isnothing(edge_labels)
        edges += Mark(:text) * Encoding(
            text=edge_labels,
            tooltip=edge_labels,
        )
    end
    =#

    return base * (Data(:name, :edges) * edges + Data(:name, :nodes) * nodes)
end

end
