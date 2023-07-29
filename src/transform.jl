###
### Transform related API
###

"""
    transform_calculate(; expressions...)
Creates a `TransformSpec` for the given calculate expressions.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/aggregate.html)
"""
transform_calculate(as::SymbolOrString, calculate::String) = Transform(; calculate, as)
function transform_calculate(; expressions...)
    transforms = [(; as, calculate) for (as, calculate) in pairs(expressions)]
    return TransformSpec(transforms)
end

"""
    transform_filter(predicate)
Creates a `TransformSpec` for the given predicate filter.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/calculate.html)
"""
transform_filter(predicate) = Transform(filter=predicate)

"""
    transform_aggregate(; [groupby], aggregations...)
Creates a `TransformSpec` for the given aggregations.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/aggregate.html)
"""
function transform_aggregate(;
    join::Bool=false,
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    aggregations...
)
    groupby isa SymbolOrString && (groupby = [groupby])
    aggregates = NamedTuple[]
    for (k, v) in aggregations
        field, op = _parse_field_operation(v)
        agg = _remove_empty(; field, op, as=k)
        push!(aggregates, agg)
    end
    aggregate = join ? nothing : aggregates
    joinaggregate = join ? aggregates : nothing
    Transform(; _remove_empty(; aggregate, joinaggregate, groupby)...)
end

"""
    transform_joinaggregate(; [groupby], aggregations...)
Creates a `TransformSpec` for the given join aggregations.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/joinaggregate.html)
"""
transform_joinaggregate(; groupby = nothing, aggregations...) = transform_aggregate(; join=true, groupby, aggregations...)

"""
    transform_timeunit(; transformations...)
Creates a `TransformSpec` for the given timeUnit transformations.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/timeunit.html)
"""
transform_timeunit(
    as::SymbolOrString, field::SymbolOrString, timeUnit
) = Transform(; timeUnit, field, as)
function transform_timeunit(; transformations...)
    if length(transformations) > 1
        @warn "Only one timeunit transformation should be given. Taking only the first..."
    end
    as, transformation = collect(transformations)[1]
    field, timeUnit = _parse_field_operation(transformation)
    return transform_timeunit(as, field, timeUnit)
end

"""
    transform_window(; [frame], [ignorePeers], [groupby],[ sortby], operations...)
Creates a `TransformSpec` for the given window operations.
If a sortby field starts with '-' then descending order is used.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/window.html)
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

    Transform(; _remove_empty(; window, frame, ignorePeers, groupby, sort)...)
end

"""
    transform_fold(fold::Vector; as=(:key, :value))
Creates a `TransformSpec` for the given fold (wide to long) transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/fold.html)
"""
transform_fold(
    fold::Vector{<:SymbolOrString};
    as::Union{Nothing, NTuple{2, SymbolOrString}, Vector{<:SymbolOrString}}=nothing,
) = Transform(; _remove_empty(; fold, as)...)

"""
    transform_pivot(pivot, value; [groupby], [limit], [op])
Creates a `TransformSpec` for the given pivot (long to wide) transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/pivot.html)
"""
function transform_pivot(
    pivot::SymbolOrString,
    value::SymbolOrString;
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    limit::Union{Nothing, Number} = nothing,
    op::Union{Nothing, SymbolOrString} = nothing,
)
    groupby isa SymbolOrString && (groupby = [groupby])
    Transform(; _remove_empty(; pivot, value, groupby, limit, op)...)
end

"""
    transform_loess(x, y; [groupby], [bandwith], [as])
Creates a `TransformSpec` for a Loess  transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/loess.html)
"""
function transform_loess(
    x::SymbolOrString,
    y::SymbolOrString;
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    bandwidth::Union{Nothing, Number} = nothing,
    as::Union{Nothing, NTuple{2, SymbolOrString}, Vector{<:SymbolOrString}}=nothing,
)
    groupby isa SymbolOrString && (groupby = [groupby])
    if !(isnothing(bandwidth) || 0 <= bandwidth <= 1)
        @warn "bandwidth should be in the range [0,1]. Setting to VegaLite's default..."
        bandwidth = nothing
    end
    Transform(;
        _remove_empty(; loess=y, on=x, groupby, bandwidth, as)...
    )
end

"""
    transform_loess(x, y; [groupby], [method], [order], [extent], [params], [as])
Creates a `TransformSpec` for a regression model transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/regression.html)
"""
function transform_regression(
    x::SymbolOrString,
    y::SymbolOrString;
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    method::Union{Nothing, SymbolOrString} = nothing,
    order::Union{Nothing, Int} = nothing,
    extent::Union{Nothing, NTuple{2, Union{Nothing, Number}}, Vector{<:Union{Nothing, Number}}} = nothing,
    params::Union{Nothing, Bool} = nothing,
    as::Union{Nothing, NTuple{2, SymbolOrString}, Vector{<:SymbolOrString}}=nothing,
)
    groupby isa SymbolOrString && (groupby = [groupby])
    Transform(;
        _remove_empty(; regression=y, on=x, groupby, method, order, extent, params, as)...
    )
end

"""
    transform_density(field; [groupby], [cumulative], [counts], [bandwith], [extent], [minsteps], [maxsteps], [steps], [as])
Creates a `TransformSpec` for a density transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/density.html)
"""
function transform_density(
    field;
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    cumulative::Union{Nothing, Bool} = nothing,
    counts::Union{Nothing, Bool} = nothing,
    bandwidth::Union{Nothing, Number} = nothing,
    extent::Union{Nothing, NTuple{2, Union{Nothing, Number}}, Vector{<:Union{Nothing, Number}}} = nothing,
    minsteps::Union{Nothing, Number} = nothing,
    maxsteps::Union{Nothing, Number} = nothing,
    steps::Union{Nothing, Number} = nothing,
    as::Union{Nothing, NTuple{2, SymbolOrString}, Vector{<:SymbolOrString}} = nothing,
)
    groupby isa SymbolOrString && (groupby = [groupby])
    Transform(;
        _remove_empty(; density=field, groupby, cumulative, counts, bandwidth, extent, minsteps, maxsteps, steps, as)...
    )
end

"""
    transform_lookup(lookup, from; [as], [default])
Creates a `TransformSpec` for a lookup transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/lookup.html)
"""
transform_lookup(
    lookup::SymbolOrString,
    from;
    as::Union{Nothing, Vector{<:SymbolOrString}} = nothing,
    default = nothing,
) = Transform(; _remove_empty(; lookup, from, as, default)...)

"""
    transform_bin(field, as; [bin])
Creates a `TransformSpec` for a bin transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/bin.html)
"""
transform_bin(
    field::SymbolOrString,
    as::Union{SymbolOrString, NTuple{2, SymbolOrString}, Vector{<:SymbolOrString}};
    bin = true,
) = Transform(; field, as, bin)

"""
    transform_bin(impute, key; [groupby], [keyvals], [frame], [method], [value])
Creates a `TransformSpec` for an impute transformation.
See more in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/impute.html)
"""
function transform_impute(
    impute::SymbolOrString,
    key::SymbolOrString;
    groupby::Union{Nothing, SymbolOrString, Vector{<:SymbolOrString}} = nothing,
    keyvals = nothing,
    frame::Union{Nothing, NTuple{2, Union{Nothing, Int}}, Vector{<:Union{Nothing, Int}}} = nothing,
    method::Union{Nothing, SymbolOrString} = nothing,
    value = nothing,
)
    groupby isa SymbolOrString && (groupby = [groupby])
    Transform(;  _remove_empty(; impute, key, groupby, keyvals, frame, method, value)...)
end

# TODO: implement rest of transformers
# transform_flatten() =
# transform_quantile() =
# transform_sample() =
# transform_stack() =
