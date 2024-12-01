module GraphsExt

using Deneb, Graphs, NetworkLayout

function node_data(g::AbstractGraph, pos; labels::Union{Nothing, AbstractVector}=nothing)
    isnothing(labels) && return [(id=v, x=pos[v][1], y=pos[v][2]) for v in vertices(g)]
    length(labels) == nv(g) || error("labels length must be equal to number of vertices")
    return [
        (id=v, x=pos[v][1], y=pos[v][2], label=l)
        for (v, l) in zip(vertices(g), labels)
    ]
end

function edge_data(g::AbstractGraph, pos; labels::Union{Nothing, AbstractVector}= nothing)
    isnothing(labels) && return [
        (src=src(e), dst=dst(e), x=pos[src(e)][1], y=pos[src(e)][2], x2=pos[dst(e)][1], y2=pos[dst(e)][2], label=repr(e))
        for e in edges(g)
    ]
    length(labels) == ne(g) || error("labels length must be equal to number of edges")
    return [
        (src=src(e), dst=dst(e), x=pos[src(e)][1], y=pos[src(e)][2], x2=pos[dst(e)][1], y2=pos[dst(e)][2], label=l)
        for (e, l) in zip(edges(g), labels)
    ]
end

function Deneb.graph_data(
    g::AbstractGraph;
    layout::NetworkLayout.AbstractLayout=Spring(),
    node_labels::Union{Nothing, AbstractVector}=nothing,
    edge_labels::Union{Nothing, AbstractVector}=nothing,
)
    pos = layout(g)
    nodes = node_data(g, pos; labels=node_labels)
    edges = edge_data(g, pos; labels=edge_labels)
    return nodes, edges
end

function Deneb.Datasets(
    g::AbstractGraph;
    layout::NetworkLayout.AbstractLayout=Spring(),
    node_labels::Union{Nothing, AbstractVector}=nothing,
    edge_labels::Union{Nothing, AbstractVector}=nothing,
)
    nodes, edges = graph_data(g; layout, node_labels, edge_labels)
    return Datasets(; nodes, edges)
end

function Deneb.plotgraph(
    g::AbstractGraph;
    layout::NetworkLayout.AbstractLayout=Spring(),
    node_labels::Union{Nothing, AbstractVector}=nothing,
    edge_labels::Union{Nothing, AbstractVector}=nothing,
)
    base = Datasets(g; layout, node_labels, edge_labels) * Encoding(
        x=field("x:q", axis=nothing),
		y=field("y:q", axis=nothing),
    )

    ntooltip = isnothing(node_labels) ? :id : [field(:id), field(:label)]
    points = Mark(
		:point, size=400, fill=:lightblue, opacity=1,
	) * Encoding(tooltip=ntooltip)
	labels = Mark(:text) * Encoding(
        text=isnothing(node_labels) ? :id : :label,
        tooltip=ntooltip,
    )

    lines = Mark(:rule, size=3) * Encoding(x2=:x2, y2=:y2, tooltip=:label)

    return base * (
        Data(:name, :edges) * lines +
        Data(:name, :nodes) * (points + labels)
    )
end

end
