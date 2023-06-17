###
### Transform related API
###

transform_calculate(as::SymbolOrString, calculate::String) = Transform(; calculate, as)
function transform_calculate(; expressions...)
    transforms = [(; as, calculate) for (as, calculate) in pairs(expressions)]
    return TransformSpec(transforms)
end

transform_filter(predicate) = Transform(filter=predicate)

function transform_aggregate(;
    join::Bool=false,
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    aggregations...
)
    groupby isa SymbolOrString && (groupby = [groupby])
    aggregates = NamedTuple[]
    for (k, v) in pairs(aggregations)
        field, op = _parse_field_operation(v)
        agg = _remove_empty(; field, op, as=k)
        push!(aggregates, agg)
    end
    aggregate = join ? nothing : aggregates
    joinaggregate = join ? aggregates : nothing
    Transform(; _remove_empty(; aggregate, joinaggregate, groupby)...)
end

transform_joinaggregate(; groupby = nothing, aggregations...) = transform_aggregate(; join=true, groupby, aggregations...)

"""
if a sortby field starts with '-' then descending order
"""
function transform_window(;
    frame::Union{Nothing, NTuple{2, Union{Nothing, Int}}, Vector{<:Union{Nothing, Int}}} = nothing,
    ignorePeers::Union{Nothing, Bool} = nothing,
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    sortby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    operations...
)
    groupby isa SymbolOrString && (groupby = [groupby])
    sortby isa SymbolOrString && (sortby = [sortby])
    if isnothing(sortby)
        sort = nothing
    else
        sort = [
            _remove_empty(;
                field=String(x)[1] == '-' ? x[2:end] : x,
                order=String(x)[1] == '-' ? "descending" : nothing,
            )
            for x in sortby
        ]
    end

    window = NamedTuple[]
    for (k, v) in pairs(operations)
        field, op, param = _parse_field_operation(v)
        param = isnothing(param) ? param : parse(Int, param)  # they are always integer
        w = _remove_empty(; field, op, param, as=k)
        push!(window, w)
    end

    nt = _remove_empty(; window, frame, ignorePeers, groupby, sort)
    Transform(; nt...)
end

"""
    transform_fold(fold::Vector; as=(:key, :value))
Wide to long transformation
"""
transform_fold(
    fold::Vector{<:SymbolOrString};
    as::Union{Nothing, NTuple{2, SymbolOrString}, Vector{<:SymbolOrString}}=nothing,
) = Transform(; _remove_empty(; fold, as)...)
