###
### Composition
###

"""
    spec1::Spec * spec2::Spec
Multiplication of two `Spec` creates a new `Spec` as a composition of the two specifications.
For instance, `spec(mark=:bar) * spec(width=300)` will be equivalent to `spec(mark=:bar, width=300)`.
Properties defined in `spec2` have precedence over `spec1`, meaning that if a given property
is specified in both then the result specification will use the property from `spec2`.
"""
Base.:*(a::Spec, b::Spec) = isnothing(value(b)) ? Spec(a) : Spec(b)
function Base.:*(a::Spec{NamedTuple}, b::Spec{NamedTuple})
    aspec, bspec = a.spec, b.spec
    properties = propertynames(aspec) ∪ propertynames(bspec)
    new_spec = NamedTuple(
        k => get(aspec, k, Spec(nothing)) * get(bspec, k, Spec(nothing))
        for k in properties
    )
    return Spec(new_spec)
end

Base.:*(a::T, b::T) where {T<:PropertiesSpec}  = T((getfield(a, f) * getfield(b, f) for f in fieldnames(T))...)

###
### Layering
###

function LayerSpec(s::SingleSpec)
    common, data, mark, encoding, width, height, view, projection = collect(
        getfield(s, f) for f in fieldnames(SingleSpec)
    )
    # Promote data, encoding, width and height specs as parent specs
    layer = [SingleSpec(; common, mark=mark.mark, view, projection)]
    LayerSpec(;data=data.data, encoding=encoding.encoding, width, height, layer=layer)
end

const SingleOrLayerSpec = Union{SingleSpec, LayerSpec}

"""
    spec1::TopLevelSpec + spec2::TopLevelSpec
The addition of two `TopLevelSpec` produces a new `TopLevelSpec` with both specs layered.
The order matters as `spec1` will appear below `spec2`.
If the specs contain common data, encoding or size properties, they will be promoted to the
top level specification.
Layering layered specification with shared data/encoding/sizes will append the layers ([s1, s2] + [s3, s4]
-> [s1, s2, s3, s4]), otherwise creating a nested layer is created ([s1, s2, [s3, s4]]).
Multi-view layout specs (facet, repeat, concat) cannot be layered.
"""
function Base.:+(a::TopLevelSpec, b::TopLevelSpec)
    if _incompatible_toplevels(a.toplevel, b.toplevel)
        @warn "Attempting to layer two specs with incompatible toplevel properties. Will use the toplevel properties from spec `a`..."
    end
    toplevel = b.toplevel * a.toplevel
    TopLevelSpec(toplevel, a.spec + b.spec)
end

function _incompatible_toplevels(a::TopLevelProperties, b::TopLevelProperties)
    (isempty(propertynames(a)) || isempty(propertynames(b))) && return false
    for p in propertynames(a)
        p in propertynames(b) && getfield(a, p) != getfield(b, p) && return true
    end
    return false
end

Base.:+(a::AbstractSpec, b::AbstractSpec) = error("Layering not implemented for $(typeof(a)) + $(typeof(b))")

# disallowed layering
Base.:+(a::LayoutSpec, ::AbstractSpec) = _layout_layering_error(a)
Base.:+(::AbstractSpec, b::LayoutSpec) = _layout_layering_error(b)
Base.:+(a::LayoutSpec, ::LayoutSpec) = _layout_layering_error(a)
_layout_layering_error(a) = error("Multiview layout spec $(typeof(a)) can not be layered")

# allowed layering
Base.:+(a::SingleSpec, b::SingleSpec) = LayerSpec(a) + LayerSpec(b)
Base.:+(a::SingleSpec, b::LayerSpec) = LayerSpec(a) + b
Base.:+(a::LayerSpec, b::SingleSpec) = a + LayerSpec(b)
function Base.:+(a::LayerSpec, b::LayerSpec)
    common, data, encoding, layer, width, height, view, projection, resolve = collect(
        getfield(b, f) for f in fieldnames(LayerSpec)
    )
    # if parent data, encoding, width and height specs are shared across layers
    # then append layers: [s1, s2] + [s3, s4] -> [s1, s2, s3, s4]
    # otherwise nest layers: [s1, s2] + [s3, s4] -> [s1, s2, [s3, s4]]
    data = _different_or_nothing(data, a.data)
    encoding = _different_or_nothing(encoding, a.encoding)
    width = _different_or_nothing(width, a.width)
    height = _different_or_nothing(height, a.height)
    alayer = deepcopy(a.layer)
    blayer = LayerSpec(;common, data=data.data, encoding=encoding.encoding, layer, width, height, view, projection, resolve)
    if isnothing(data.data) && isnothing(value(encoding.encoding)) && isnothing(value(width)) && isnothing(value(height))
        append!(alayer, blayer.layer)
    else
        push!(alayer, blayer)
    end
    LayerSpec(
        a.common,
        a.data,
        a.encoding,
        alayer,
        a.width,
        a.height,
        a.view,
        a.projection,
        a.resolve
    )
end

function _different_or_nothing(s1, s)
    (s1 != s || isnothing(value(s1))) && return s1
    typeof(s1) === Spec ? Spec(nothing) : typeof(s1)(Spec(nothing))
end

###
### Concatenation
###

# TODO: to be implemented
