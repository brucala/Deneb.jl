###
### Params related API
###

"""
    interactive_scales(;bindx=true, bindy=true, shift_on_y=false)

Creates a `ParamsSpec` that can be composed to other specs to create interactive pan
(mouse hold and drag) and zoom (mouse wheel) charts.
`bindx` and `bindy` specify if the `x` and `y` channels are to be bound.
If `shift_on_y` is true, then the shift key must be hold to pan and zoom in the `y` channel.
"""
function interactive_scales(; bindx=true, bindy=true, shift_on_y=false)
    name, select, bind = :interactive_scales, :interval, :scales
    bindx && bindy && !shift_on_y && return Params(;name, select, bind)

    if !bindx && !bindy
        @warn "At least one of `bindx` and `bindy` must be true for interactive scales."
    end

    params = Params()
    if bindx
        namex = Symbol(String(name) * "_x")
        select = (type=:interval, encodings=[:x])
        if bindy && shift_on_y
            zoom = "wheel![!event.shiftKey]"
            translate = "[mousedown[!event.shiftKey], mouseup] > mousemove"
            select = (;select..., zoom, translate)
            end
        params *= Params(;name=namex, select, bind)
    end
    if bindy
        namey = Symbol(String(name) * "_y")
        select = (type=:interval, encodings=[:y])
        if shift_on_y
            zoom = "wheel![event.shiftKey]"
            translate = "[mousedown[event.shiftKey], mouseup] > mousemove"
            select = (;select..., zoom, translate)
            end
        params *= Params(;name=namey, select, bind)
    end
    return params
end

"""
    select(type, name; value, bind, select_options...)
Convenient function to create a `ParamsSpec` with the following structure:
```json
{
  "name": name,
  "value": value,
  "select": {
    "type": type,
    select_options...
  },
  "bind": bind
}
```
"""
function select(type::SymbolOrString, name::SymbolOrString; value=nothing, bind=nothing, select_options...)
    if isnothing(select_options)
        select = type
    else
        select = (; type, select_options...)
    end
    isnothing(value) && isnothing(bind) && return Params(; name, select)
    isnothing(value) && return Params(; name, select, bind)
    isnothing(bind) && return Params(; name, value, select)
    return Params(; name, value, select, bind)
end

"""
    select_point()
"""
select_point(name::SymbolOrString; value=nothing, bind=nothing, select_options...) = select(:point, name; value, bind, select_options...)

"""
    select_interval()
"""
select_interval(name::SymbolOrString; value=nothing, bind=nothing, select_options...) = select(:interval, name; value, bind, select_options...)

"""
    select_legend(name; encodings=:color, fields=nothing, bind_options=nothing)

Creates a `ParamSpec` named `name` that can be composed to other specs to create selectable legends bound
to the given `encoding` or `field`.
To customize the events that trigger legend interaction, set `bind_options` with a property
that maps to a Vega event stream (e.g. "dblclick").
More info about legend binding: https://vega.github.io/vega-lite/docs/bind.html#legend-binding
"""
function select_legend(
    name::SymbolOrString;
    encoding::Union{Nothing, SymbolOrString}=nothing,
    field::Union{Nothing, SymbolOrString}=nothing,
    bind_options=nothing,
)
    if isnothing(encoding) && isnothing(field)
        encoding = :color
    end
    if !isnothing(encoding) && !isnothing(field)
        @warn "Only one `encoding` or `field` must be given to select_legend. `field` will be ignored"
    end

    if !isnothing(encoding)
        select = (type=:point, encodings=[encoding])
    else
        select = (type=:point, fields=[field])
    end

    if isnothing(bind_options)
        bind=:legend
    else
        bind=(; legend=bind_options)
    end
    return Params(; name, select, bind)
end

"""
    select_bind_input(type, name; value, select, bind_options...)
Convenient function to create a `ParamsSpec` with the following structure:
```json
{
  "name": name,
  "value": value,
  "select": select,
  "bind": {
    "input": type,
    bind_options...
  }
}
```
"""
function select_bind_input(type::SymbolOrString, name::SymbolOrString; value=nothing, select=nothing, bind_options...)
    bind = (input=type, bind_options...)
    isnothing(value) && isnothing(select) && return Params(; name, bind)
    isnothing(value) && return Params(; name, select, bind)
    isnothing(select) && return Params(; name, value, bind)
    return Params(; name, value, select, bind)
end

"""
    select_range(type, name; value, select, bind_options...)
"""
function select_range(name::SymbolOrString; value=nothing, select=nothing, bind_options...)
    return select_bind_input(:range, name; value, select, bind_options...)
end

"""
    select_dropdown(type, name; options, value, select, bind_options...)
options is required
"""
function select_dropdown(name::SymbolOrString; options, value=nothing, select=nothing, bind_options...)
    return select_bind_input(:select, name; value, select, options, bind_options...)
end

"""
    select_radio(type, name; options, value, select, bind_options...)
options is required
"""
function select_radio(name::SymbolOrString; options, value=nothing, select=nothing, bind_options...)
    return select_bind_input(:radio, name; value, select, options, bind_options...)
end

"""
    select_checkbox(type, name; value, select, bind_options...)
"""
function select_checkbox(name::SymbolOrString; value=nothing, select=nothing, bind_options...)
    return select_bind_input(:checkbox, name; value, select, bind_options...)
end

"""
    condition(param::String, iftrue, iffalse)
    condition_test(test::String, iftrue, iffalse)
If iftrue/iffalse isn't a NamedTuple, then it'll be converted as a NamedTuple with name :value.
"""
condition(param::SymbolOrString, iftrue, iffalse=nothing) = (condition=(; param, _value(iftrue)...), _value(iffalse)...)
condition_test(test::SymbolOrString, iftrue, iffalse=nothing) = (condition=(; test, _value(iftrue)...), _value(iffalse)...)
_value(x::NamedTuple) = x
_value(::Nothing) = (;)
_value(x) = (; value=x)
