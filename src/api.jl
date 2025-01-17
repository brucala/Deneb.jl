"""
    spec(s)

Creates an arbitrary Vega-Lite spec.
"""
spec(s) = Spec(s)
spec(; s...) = Spec(NamedTuple(s))
spec(s::VegaLiteSpec) = Spec(rawspec(s))
spec(s::DataSpec) = spec(data = rawspec(s))
spec(s::TransformSpec) = spec(transform = rawspec(s))
spec(s::ParamsSpec) = spec(params = rawspec(s))
spec(s::MarkSpec) = spec(mark = rawspec(s))
spec(s::EncodingSpec) = spec(encoding = rawspec(s))

"""
    vlspec(s)

Creates a Vega-Lite spec enforcing certain Vega-Lite constrains.

# Example
```julia
vlspec(
    data=(; url="https://vega.github.io/vega-datasets/data/seattle-weather.csv"),
    mark=:bar,
    encoding=(
        x=(timeUnit=:month, field=:date, type=:ordinal),
        y=(aggregate=:mean, field=:precipitation),
    )
)
```
"""
vlspec(s::Spec) = VegaLiteSpec(; rawspec(s)...)
vlspec(s::NamedTuple) = VegaLiteSpec(; s...)
vlspec(; s...) = VegaLiteSpec(; s...)
vlspec(s::ConstrainedSpec) = VegaLiteSpec(; rawspec(s)...)
#vlspec(s::DatasetsSpec) = VegaLiteSpec(datasets = rawspec(s))
vlspec(s::DataSpec) = VegaLiteSpec(data = rawspec(s))
vlspec(s::TransformSpec) = VegaLiteSpec(transform = rawspec(s))
vlspec(s::ParamsSpec) = VegaLiteSpec(params = rawspec(s))
vlspec(s::MarkSpec) = VegaLiteSpec(mark = rawspec(s))
vlspec(s::EncodingSpec) = VegaLiteSpec(encoding = rawspec(s))
vlspec(s::VegaLiteSpec) = VegaLiteSpec(s.toplevel, s.viewspec)


"""
    Data(table)
    Data(; url, [format], [name])
    Data(generator::SymbolOrString; properties...)

Creates a `DataSpec` containing the `data` property of a viewable specification.
Available constructors are:
- using a `table` that supports the [Tables.jl interface](https://github.com/JuliaData/Tables.jl)
- using a `url` to load the data from, with optional `format` and `name` properties. [](https://vega.github.io/vega-lite/docs/data.html#url)
- using a `generator` with specific `properties` to a use any of the available [Vega-Lite data generator](https://vega.github.io/vega-lite/docs/data.html#data-generators)

See more in [Vega-Lite's](https://vega.github.io/vega-lite/docs/data.html) and [Deneb's](https://brucala.github.io/Deneb.jl/dev/data_mark_encoding/#Data) documentation.

# Examples

    # table format
    data = (a=[1, 2], b=["potato", "tomato"])
    Data(data)

    # data from url
    Data(
        url="https://vega.github.io/vega-datasets/data/us-10m.json",
        format=(type=:topojson, feature=:states),
    )

    # Vega-Lite gererator
    Data(:graticule, step=[15, 15])
"""
Data(data) = DataSpec(data)
Data(;
    url::String,
    name::Union{Nothing, SymbolOrString}=nothing,
    format=nothing,
) = DataSpec(_remove_empty(;url, format, name))
function Data(generator::SymbolOrString; kw...)
    kw = isempty(kw) ? true : kw
    Data(NamedTuple{(generator,)}((NamedTuple(kw), )))
end
Data(key::SymbolOrString, value::SymbolOrString) = Data(NamedTuple{(key,)}((value, )))

"""
    Datasets(; datasets...)

Creates a top-level `dataspec` with the given datasets (values) and names (keywords).
The datasets can be given as tables that supports the [Tables.jl interface](https://github.com/JuliaData/Tables.jl).
"""
function Datasets(; datasets...)
    names = keys(datasets)
    tables = (_rowtable(t) for t in values(datasets))
    return vlspec(datasets=NamedTuple(zip(names, tables)))
    #return DatasetsSpec(spec(NamedTuple(zip(names, tables))))
end

_rowtable(table) = Tables.istable(table) && !Tables.isrowtable(table) ? Tables.rowtable(table) : table

"""
    Transform(; spec...)

Creates a `TransformSpec` containing the `transform` property of a viewable specification.
See also the more convenient `transform_*` methods.
"""
Transform(; s...) = TransformSpec(spec(; s...))

"""
    Params(; spec...)

Creates a `ParamsSpec` containing the `params` property of a viewable specification.
See also the more convenient `select_*` methods and the `interactive_scales` function.
"""
Params(; s...) = ParamsSpec(spec(; s...))

"""
    Facet(; [row], , [column], kw...)
    Facet(field; columns::Int=nothing, kw...)

Creates a `FacetSpec` for a facet specification. [](https://vega.github.io/vega-lite/docs/facet.html).
A `field` can be passed as a positional argument, or must be passed in the `row`/`column` keyword argument.
# Examples
```
Facet("site:O", columns=2, sort=(op=:median, field=:yield))
Facet(row="Origin:N)
```
"""
Facet(f; columns::Union{Nothing, Int}=nothing, kw...) = FacetSpec(; facet=(; field(f)..., kw...), columns)
function Facet(;
    row::Union{Nothing, SymbolOrString, NamedTuple}=nothing,
    column::Union{Nothing, SymbolOrString, NamedTuple}=nothing,
    kw...
)
    if isnothing(row) && isnothing(column)
        return error("`Facet` without positional arguments needs at least the `row` or the `column` property.")
    end
    return FacetSpec(; facet=(; _remove_empty(;row=field(row), column=field(column))..., kw...))
end

"""
    Repeat(; [row::Vector], [column::Vector], [layer::Vector])
    Repeat(field::Vector{SymbolOrString}; columns::Int=nothing)

Creates a `RepeatSpec` for a repeat specification. [](https://vega.github.io/vega-lite/docs/repeat.html).
A `field` can be passed as a positional argument, or must be passed in the `row`/`column/layer` keyword argument.
# Examples
```
Repeat([:Horsepower, :Miles_per_Gallon, :Acceleration], columns=2)
Repeat(column=[:distance, :delay, :time])
```
"""
Repeat(v::Vector{<:SymbolOrString}; columns::Union{Nothing, Int}=nothing) = RepeatSpec(; repeat=v, columns)
function Repeat(;
    row::Union{Nothing, Vector{<:SymbolOrString}}=nothing,
    column::Union{Nothing, Vector{<:SymbolOrString}}=nothing,
    layer::Union{Nothing, Vector{<:SymbolOrString}}=nothing,
)
    if isnothing(row) && isnothing(column) && isnothing(layer)
        return error("`Repeat` without positional arguments needs at least any of the `row`, `column`, or `layer` properties.")
    end
    return RepeatSpec(; repeat=(; _remove_empty(; row, column, layer)...))
end

"""
    Mark(type; kw...)
    Mark(; spec...)

Creates a `MarkSpec` containing the `mark` property of a single view specification.
The `type` property of the mark can be specified as a positional argument.
See more in [Vega-Lite's](https://vega.github.io/vega-lite/docs/mark.html) and
[Deneb's](https://brucala.github.io/Deneb.jl/dev/data_mark_encoding/#Mark) documentation.
"""
Mark(type::SymbolOrString; kw...) = MarkSpec(spec(;type=type, kw...))
Mark(; s...) = MarkSpec(spec(; s...))

"""
    Encoding(x; channels...)
    Encoding(x, y; channels...)
    Encoding(; channels...)

Creates an `EncodingSpec` containing the `encoding` property of a single or layer view specification.
The `x` and `y` channels can be specified as positional arguments using the shorthad string syntax.
See more in [Vega-Lite's](https://vega.github.io/vega-lite/docs/encoding.html) and
[Deneb.jl's](https://brucala.github.io/Deneb.jl/dev/data_mark_encoding/#Encoding).

# Examples

```
Encoding("monthdate(date):T", "mean(precipitation):Q", color="year(date):O")
Encoding(
    x=field("bin_min:Q", bin=:binned, title="Maximum Daily Temperature (C)"),
    y=field("value:Q", scale=(range=[20, -20]), axis=nothing),
    fill=field="mean_temp:Q",
)
```
"""
Encoding(x::SymbolOrString; kw...) = Encoding(; kw...) * Encoding(x=field(x))
Encoding(x::SymbolOrString, y::SymbolOrString; kw...) = Encoding(; kw...) * Encoding(x=field(x)) * Encoding(y=field(y))
Encoding(; s...) = EncodingSpec(spec(NamedTuple(k=>field(v) for (k,v) in pairs(s))))

"""
    field(field; kw...)
Shortcut to create an arbitrary encoding channel, the positional argument `field`
can use the shorthand string syntax (e.g. "mean(x):Q").
"""
field(f) = f
field(f::Symbol; kw...) = (field=f, kw...)
function field(f::AbstractString; kw...)
    fielddict = Dict{Symbol, AbstractString}()
    if occursin(":", f)
        f, type = split(f, ":")
        fielddict[:type] = _type(type)
    end
    field, op = _parse_field_operation(f)
    if !isnothing(op)
        agg_property = op in TIMEUNITS ? :timeUnit : :aggregate
        fielddict[agg_property] = op
    end
    isnothing(field) || (fielddict[:field] = field)
    return (; fielddict..., kw...)
end

"""
    layout(; align, bounds, center, spacing, columns)
Set layout properties. Needs to be composed with a LayoutSpec (Repeat, Facet, Concat).
"""
layout(; align=nothing, bounds=nothing, center=nothing, spacing=nothing, columns=nothing) = LayoutProperties(;align, bounds, center, spacing, columns)

"""
    projection(type; kw...)
Sets the projection properties.
"""
projection(type; kw...) = vlspec(; projection=(; type, kw...))

"""
    resolve(type; channels...)
    resolve(type, channel, option)

Creates a `ResolveSpec`. The `type` indicates the resolution to be defined: `scale`, `axis`, or `legend`.

For scales, resolution can be specified for every channel. For axes, resolutions can be defined for positional channels (`x`, `y`, `xOffset`, `yOffset`).
For legends, resolutions can be defined for non-positional channels (`color`, `opacity`, `shape`, and `size`).

There are two options to resolve a scale, axis, or legend: `shared` and `independent`. Independent scales imply independent axes and legends.

The defaults are documented in Vega-Lite's [documentation](https://vega.github.io/vega-lite/docs/resolve.html).

# Example
    resolve(:scale, color=:independent)
"""
function resolve(type::SymbolOrString, channel::SymbolOrString, option::SymbolOrString)
    nt = NamedTuple{(Symbol(channel),)}((option,))
    resolve(type; nt...)
end
function resolve(type; channels...)
    _validate_resolve(type; channels...)
    nt = NamedTuple{(Symbol(type),)}((channels,))
    return ResolveSpec(Spec(nt))
end

"""
    resolve_scale(; channels...)

Alias to `resolve(:scale; channels...)`
"""
resolve_scale(; channels...) = resolve(:scale; channels...)

"""
    resolve_axis(; channels...)

Alias to `resolve(:axis; channels...)`
"""
resolve_axis(; channels...) = resolve(:axis; channels...)

"""
    resolve_legend(; channels...)

Alias to `resolve(:legend; channels...)`
"""
resolve_legend(; channels...) = resolve(:legend; channels...)

function _validate_resolve(type; channels...)
    positional_channels = (:x, :y, :xOffset, :yOffset)
    non_positional_channels = (:color, :opacity, :shape, :size)
    allowed_channels = Dict(
        :scale => positional_channels ∪ non_positional_channels,
        :axis => positional_channels,
        :legend => non_positional_channels,
    )
    if Symbol(type) ∉ (:scale, :axis, :legend)
        @warn "resolve type must be `scale`, `axis`, or `legend`."
        @warn "$type resolve will probably be ignored"
    else
        for (channel, option) in channels
            if channel ∉ allowed_channels[type]
                @warn "channel for $type resolution must be $(allowed_channels[type]), `$channel` given"
                @warn "$type resolve for channel $channel will probably be ignored"
            elseif Symbol(option) ∉ (:shared, :independent)
                @warn "resolve option must be `shared` or `independent`, `$option` given"
                @warn "$type resolve for channel $channel will probably be ignored"
            end
        end
    end
end

"""
    title(title)
"""
title(title::SymbolOrString) = vlspec(title=title)
title(; properties...) = vlspec(title=properties)


"""
    config(; properties...)
    config(type; properties...)
"""
config(;properties...) = vlspec(config=properties)
function config(type::SymbolOrString; properties...)
    vlspec(
        config=NamedTuple{(type,)}((properties,))
    )
end

"""
    expr(expr)

Convenient function to create an expr spec: `{"expr": expr}`.
"""
expr(expr::SymbolOrString) = (; expr)

"""
    param(param)

Convenient function to create a param spec: `{"param": param}`.
"""
param(param::SymbolOrString) = (; param)

###
### Helper functions and constants
###

function _parse_field_operation(s::AbstractString)
    endswith(s, ")") || return s, nothing, nothing
    op, args = split(s[1:end-1], "(")
    if !occursin(",", args)
        field = args == "" ? nothing : args
        return field, op, nothing
    end
    field, param = strip.(split(args, ","))
    return field, op, param
end

_remove_empty(;values...) = NamedTuple(k => v for (k, v) in pairs(values) if !isnothing(v))

const TYPEMAP = Dict(
    "q" => "quantitative",
    "o" => "ordinal",
    "n" => "nominal",
    "t" => "temporal",
    "g" => "geojson",
)
function _type(t::AbstractString)
    t = lowercase(t)
    return get(TYPEMAP, t, t)
end

# timeUnits from vega-lite version 4.17.0
const TIMEUNITS = [
    "year",
    "quarter",
    "month",
    "week",
    "day",
    "dayofyear",
    "date",
    "hours",
    "minutes",
    "seconds",
    "milliseconds",
    "yearquarter",
    "yearquartermonth",
    "yearmonth",
    "yearmonthdate",
    "yearmonthdatehours",
    "yearmonthdatehoursminutes",
    "yearmonthdatehoursminutesseconds",
    "yearweek",
    "yearweekday",
    "yearweekdayhours",
    "yearweekdayhoursminutes",
    "yearweekdayhoursminutesseconds",
    "yeardayofyear",
    "quartermonth",
    "monthdate",
    "monthdatehours",
    "monthdatehoursminutes",
    "monthdatehoursminutesseconds",
    "weekday",
    "weeksdayhours",
    "weekdayhoursminutes",
    "weekdayhoursminutesseconds",
    "dayhours",
    "dayhoursminutes",
    "dayhoursminutesseconds",
    "hoursminutes",
    "hoursminutesseconds",
    "minutesseconds",
    "secondsmilliseconds",
    "utcyear",
    "utcquarter",
    "utcmonth",
    "utcweek",
    "utcday",
    "utcdayofyear",
    "utcdate",
    "utchours",
    "utcminutes",
    "utcseconds",
    "utcmilliseconds",
    "utcyearquarter",
    "utcyearquartermonth",
    "utcyearmonth",
    "utcyearmonthdate",
    "utcyearmonthdatehours",
    "utcyearmonthdatehoursminutes",
    "utcyearmonthdatehoursminutesseconds",
    "utcyearweek",
    "utcyearweekday",
    "utcyearweekdayhours",
    "utcyearweekdayhoursminutes",
    "utcyearweekdayhoursminutesseconds",
    "utcyeardayofyear",
    "utcquartermonth",
    "utcmonthdate",
    "utcmonthdatehours",
    "utcmonthdatehoursminutes",
    "utcmonthdatehoursminutesseconds",
    "utcweekday",
    "utcweeksdayhours",
    "utcweekdayhoursminutes",
    "utcweekdayhoursminutesseconds",
    "utcdayhours",
    "utcdayhoursminutes",
    "utcdayhoursminutesseconds",
    "utchoursminutes",
    "utchoursminutesseconds",
    "utcminutesseconds",
    "utcsecondsmilliseconds",
]
