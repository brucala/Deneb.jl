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
    g::AbstractGraph;
    layout::NetworkLayout.AbstractLayout=Spring(),
    labelsize::Int=11,
    node_labels::Union{Bool, Deneb.SymbolOrString, AbstractVector, Bool}=false,
    edge_labels::Union{Bool, Deneb.SymbolOrString, AbstractVector, Bool}=false,
    node_colors::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    edge_colors::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    node_color_type::Union{Nothing, Deneb.SymbolOrString}=nothing,
    edge_color_type::Union{Nothing, Deneb.SymbolOrString}=nothing,
    node_sizes::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    edge_widths::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    node_size_type::Union{Nothing, Deneb.SymbolOrString}=nothing,
    edge_width_type::Union{Nothing, Deneb.SymbolOrString}=nothing,
    node_shapes::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    edge_dashes::Union{Nothing, Deneb.SymbolOrString, AbstractVector}=nothing,
    attributes...
)

    node_label, node_color, node_size, node_shape = fill(nothing, 4)
    edge_label, edge_color, edge_width, edge_dash = fill(nothing, 4)
    if node_labels isa AbstractVector
        node_label = node_labels
        node_labels = :label
    elseif node_labels == true
        node_labels = :id
    end
    if edge_labels isa AbstractVector
        edge_label = edge_labels
        edge_labels = :label
    elseif edge_labels == true
        edge_labels = :label
    end
    if node_colors isa AbstractVector
        # auto infer color type
        if isnothing(node_color_type)
            node_color_type = eltype(node_colors) <: Number ? :q : :n
        end
        node_color = node_colors
        node_colors = "color:$node_color_type"
    elseif !isnothing(node_colors)
        node_colors = "$node_colors:$(something(node_color_type, :n))"
    end
    if edge_colors isa AbstractVector
        # auto infer color type
        if isnothing(edge_color_type)
            edge_color_type = eltype(edge_colors) <: Number ? :q : :n
        end
        edge_color = edge_colors
        edge_colors = "color:$edge_color_type"
    elseif !isnothing(edge_colors)
        edge_colors = "$edge_colors:$(something(edge_color_type, :n))"
    end
    if node_sizes isa AbstractVector
        # auto infer size type
        if isnothing(node_size_type)
            node_size_type = eltype(node_sizes) <: Number ? :q : :n
        end
        node_size = node_sizes
        node_sizes = "size:$node_size_type"
    elseif !isnothing(node_sizes)
        node_sizes = "$node_sizes:$(something(node_size_type, :n))"
    end
    if edge_widths isa AbstractVector
        # auto infer size type
        if isnothing(edge_width_type)
            edge_width_type = eltype(edge_widths) <: Number ? :q : :n
        end
        edge_width = edge_widths
        edge_widths = "width:$edge_width_type"
    elseif !isnothing(edge_widths)
        edge_widths = "$edge_widths:$(something(edge_width_type, :n))"
    end
    if node_shapes isa AbstractVector
        node_shape = node_shapes
        node_shapes = :shape
    end
    if edge_dashes isa AbstractVector
        edge_dash = edge_dashes
        edge_dashes = :dash
    end

    base = Datasets(
        g, layout;
        node_label, node_color, node_size, node_shape, edge_label, edge_color, edge_width, edge_dash, attributes...
    ) * Encoding(
        x=field("x:q", axis=nothing),
		y=field("y:q", axis=nothing),
    ) * config(view=(; stroke=""))

    node_tooltip = isnothing(node_labels) ? :id : [field(:id), field(node_labels)]

    nodes = Mark(
		:point, size=400, fill=:lightblue, opacity=1,
	) * Encoding(tooltip=node_tooltip)

    !isnothing(node_colors) && (nodes *= Encoding(fill=node_colors))
    !isnothing(node_sizes) && (nodes *= Encoding(size=node_sizes))
    !isnothing(node_shapes) && (nodes *= Encoding(shape=node_shapes))

    if node_labels != false
        nodes += Mark(:text, font=:monospace, fontSize=labelsize) * Encoding(
            text=node_labels,
            tooltip=node_tooltip,
        )
    end

    esize = !isnothing(edge_widths) ? (;) : (size=3,)
    edges = Mark(:rule; esize...) * Encoding(x2=:x2, y2=:y2, tooltip=:label) * interactive_scales()

    !isnothing(edge_colors) && (edges *= Encoding(color=edge_colors))
    !isnothing(edge_widths) && (edges *= Encoding(strokeWidth=edge_widths))
    !isnothing(edge_dashes) && (edges *= Encoding(strokeDash=edge_dashes))

    if edge_labels != false
        # white background box around text
        # box size is corrected by size of figure and size of text, assumes the monospace font
        # TODO: set angle in the direction of the edge
        edges += Mark(:rect, color=:white) * transform_calculate(
            x="(datum.x + datum.x2)/2 - length(toString(datum.label)) * 15 / width * $labelsize / 11",
            y="(datum.y + datum.y2)/2 - 25 / height * $labelsize / 11",
            x2="datum.x + length(toString(datum.label)) * 30 / height * $labelsize / 11",
            y2="datum.y + 52 / height * $labelsize / 11",
        ) * Encoding(
            x2=:x2,
            y2=:y2,
            text=edge_labels,
            tooltip=edge_labels,
        )
        # labels
        edges += Mark(
            :text, font=:monospace, fontSize=labelsize
        ) * transform_calculate(
            x="(datum.x + datum.x2)/2",
            y="(datum.y + datum.y2)/2",
        ) * Encoding(
            text=edge_labels,
            tooltip=edge_labels,
        )
    end

    return base * (Data(:name, :edges) * edges + Data(:name, :nodes) * nodes)
end

end
