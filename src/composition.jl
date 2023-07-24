###
### Composition
###

"""
    spec1::AbstractSpec * spec2::AbstractSpec
Multiplication of two `AbstractSpec` creates a new `AbstractSpec` as a composition of the
two specifications. For instance, `vlspec(mark=:bar) * vlspec(title="chart")` will be
equivalent to `vlspec(mark=:bar, title="chart")`.
Properties defined in `spec2` have precedence over `spec1`, meaning that if a given property
is specified in both, then the result specification will use the property from `spec2`.
If the types of the two specs are different then the result spec will be a VegaLiteSpec.
"""
Base.:*(a::Spec, b::Spec) = isnothing(rawspec(b)) ? Spec(a) : Spec(b)
function Base.:*(a::Spec{<:Vector}, b::Spec{<:Vector})
    aspec, bspec = a.spec, b.spec
    bspec = [x for x in bspec if x ∉ aspec]
    return Spec(vcat(aspec, bspec))
end
function Base.:*(a::Spec{NamedTuple}, b::Spec{NamedTuple})
    aspec, bspec = a.spec, b.spec
    properties = propertynames(aspec) ∪ propertynames(bspec)
    new_spec = NamedTuple(
        k => get(aspec, k, Spec(nothing)) * get(bspec, k, Spec(nothing))
        for k in properties
    )
    return Spec(new_spec)
end

Base.:*(a::Spec, b::ConstrainedSpec) = vlspec(spec(a) * spec(b))
Base.:*(a::ConstrainedSpec, b::Spec) = vlspec(spec(a) * spec(b))

Base.:*(a::T, b::T) where {T<:ConstrainedSpec}  = T((getfield(a, f) * getfield(b, f) for f in fieldnames(T))...)
Base.:*(a::VegaLiteSpec, b::VegaLiteSpec)  = VegaLiteSpec((getfield(a, f) * getfield(b, f) for f in fieldnames(VegaLiteSpec))...)
Base.:*(a::DataSpec, b::DataSpec) = isnothing(rawspec(b)) ? DataSpec(rawspec(a)) : DataSpec(rawspec(b))
Base.:*(a::ConstrainedSpec, b::ConstrainedSpec) = vlspec(a) * vlspec(b)

Base.:*(::LayerSpec, ::LayerSpec) = error("Two layered specs can not be composed.")
function Base.:*(a::SingleSpec, b::LayerSpec)
    # if single spec on the left, compose its properties with the top level properties of layer giving precedence to single spec
    s = SingleSpec(mark=rawspec(a.mark))
    LayerSpec(
        b.common * a.common,
        b.transform * a.transform,
        b.params * a.params,
        b.data * a.data,
        b.encoding * a.encoding,
        [s * l for l in b.layer],
        b.width * a.width,
        b.height * a.height,
        b.view * a.view,
        b.projection * a.projection,
        b.resolve
    )
end
function Base.:*(a::LayerSpec, b::SingleSpec)
    # if single spec on the right, compose directly with each layer
    LayerSpec(
        a.common,
        a.transform,
        a.params,
        a.data,
        a.encoding,
        [l * b for l in a.layer],
        a.width,
        a.height,
        a.view,
        a.projection,
        a.resolve
    )
end

function Base.:*(a::T, b::SingleOrLayerSpec) where T <: LayoutSpec
    # if single/layer spec on the right, compose directly the layout spec
    T(
        a.common,
        a.transform,
        a.params,
        a.layout,
        a.data,
        a.spec * b,
        getfield(a, _key(T)),
        a.resolve
    )
end
function Base.:*(a::SingleOrLayerSpec, b::T) where T <: LayoutSpec
    # if single/layer spec on the left, compose its properties with the top level properties of layer giving precedence to single spec
    T(
        b.common * a.common,
        b.transform * a.transform,
        b.params * a.params,
        b.layout,
        b.data * a.data,
        b.spec * _remove_fields(a, :common, :transform, :params, :data),
        getfield(b, _key(T)),
        b.resolve
    )
end


Base.:*(a::VegaLiteSpec, b::LayoutProperties) = VegaLiteSpec(a.toplevel, a.viewspec * b)
function Base.:*(a::T, b::LayoutProperties) where T<:LayoutSpec
    T(
        (f === :layout ? b : getfield(a, f) for f in fieldnames(T))...
    )
end

Base.:*(::ConcatView, ::ConcatView) = error("Two concat specs can not be composed.")
function Base.:*(a::SingleSpec, b::T) where T<:ConcatView
    # if single spec on the left, compose its properties with the top level properties of layer giving precedence to single spec
    s = SingleSpec(
        mark=rawspec(a.mark),
        encoding=rawspec(a.encoding),
        width=rawspec(a.width),
        height=rawspec(a.height),
        view=rawspec(a.view),
        projection=rawspec(a.projection),
    )
    T(
        b.common * a.common,
        b.transform * a.transform,
        b.params * a.params,
        b.layout,
        b.data * a.data,
        [s * l for l in getfield(b, _key(T))],
        b.resolve
    )
end
function Base.:*(a::T, b::SingleSpec) where T<:ConcatView
    # if single spec on the right, compose directly with each layer
    T(
        a.common,
        a.layout,
        data=a.data,
        [l * b for l in getfield(a, _key(T))],
        a.resolve
    )
end

_key(::Type{ConcatSpec}) = :concat
_key(::Type{HConcatSpec}) = :hconcat
_key(::Type{VConcatSpec}) = :vconcat
_key(::Type{FacetSpec}) = :facet
_key(::Type{RepeatSpec}) = :repeat

function _remove_fields(s::T, fields...) where T<:ConstrainedSpec
    kw = Dict(
        field => getfield(s, field)
        for field in fieldnames(T)
        if field ∉ fields
    )
    typeof(s)(;kw...)
end

Base.:*(a::T, b::ResolveSpec) where T<:VegaLiteSpec{<:MultiViewSpec} = a * spec(resolve=b)
Base.:*(a::ResolveSpec, b::T) where T<:VegaLiteSpec{<:MultiViewSpec} = b * a

###
### Layering
###

"""
    spec1::ConstrainedSpec + spec2::ConstrainedSpec
The addition of two specs will produce a new spec with both specs layered.
The order matters as `spec1` will appear below `spec2`.
If the specs contain shared properties (e.g. `data`, `encoding`, `width`...),
they will be promoted to the top level specification.
Multi-view layout specs (facet, repeat, concat) cannot be layered. However,
layered specs can be faceted/repeated/concatenated.
"""
function Base.:+(a::VegaLiteSpec, b::VegaLiteSpec)
    if _incompatible_toplevels(a.toplevel, b.toplevel)
        @warn "Attempting to layer two specs with incompatible toplevel properties. Will use the toplevel properties from spec `a`..."
    end
    toplevel = b.toplevel * a.toplevel
    VegaLiteSpec(toplevel, a.viewspec + b.viewspec)
end

function _incompatible_toplevels(a::TopLevelProperties, b::TopLevelProperties)
    (isempty(propertynames(a)) || isempty(propertynames(b))) && return false
    for p in propertynames(a)
        p in propertynames(b) && getfield(a, p) != getfield(b, p) && return true
    end
    return false
end

Base.:+(a::AbstractSpec, b::AbstractSpec) = error("Layering not implemented for $(typeof(a)) + $(typeof(b))")
Base.:+(a::ConstrainedSpec, b::ConstrainedSpec) = vlspec(a) + vlspec(b)

# disallowed layering
Base.:+(a::LayoutSpec, ::AbstractSpec) = _layout_layering_error(a)
Base.:+(::AbstractSpec, b::LayoutSpec) = _layout_layering_error(b)
Base.:+(a::LayoutSpec, ::LayoutSpec) = _layout_layering_error(a)
_layout_layering_error(a) = error("Multiview layout spec $(typeof(a)) can not be layered")

# allowed layering
function Base.:+(a::SingleSpec, b::SingleSpec)
    shared, a, b = _extract_shared(a, b, fieldnames(LayerSpec))
    layer = [a, b]
    LayerSpec(; layer=layer, shared...)
end
function Base.:+(a::SingleSpec, b::LayerSpec)
    shared, a, b = _extract_shared(a, b, fieldnames(LayerSpec))
    if _has_properties_other_than_layer(b)
        layer = Union{SingleSpec, LayerSpec}[a, b.layer...]
    else
        layer = Union{SingleSpec, LayerSpec}[a, b]
    end
    LayerSpec(; layer=layer, shared...)
end
# don't use b+a because order matters
function Base.:+(a::LayerSpec, b::SingleSpec)
    shared, a, b = _extract_shared(a, b, fieldnames(LayerSpec))
    if _has_properties_other_than_layer(a)
        layer = Union{SingleSpec, LayerSpec}[a.layer..., b]
    else
        layer = Union{SingleSpec, LayerSpec}[a, b]
    end
    LayerSpec(; layer=layer, shared...)
end
function Base.:+(a::LayerSpec, b::LayerSpec)
    to_extract = setdiff(fieldnames(LayerSpec), [:layer])
    shared, a, b = _extract_shared(a, b, to_extract)
    expand_a = _has_properties_other_than_layer(a)
    expand_b = _has_properties_other_than_layer(b)
    if expand_a & expand_b
        layer = Union{SingleSpec, LayerSpec}[a.layer..., b.layer...]
    elseif expand_a
        layer = Union{SingleSpec, LayerSpec}[a.layer..., b]
    elseif expand_b
        layer = Union{SingleSpec, LayerSpec}[a, b.layer...]
    else
        layer = Union{SingleSpec, LayerSpec}[a, b]
    end
    LayerSpec(; layer=layer, shared...)
end

_has_properties_other_than_layer(s) = isempty(setdiff(propertynames(s), [:layer]))

function _extract_shared(s1::ConstrainedSpec, s2::ConstrainedSpec, fields)
    shared = Dict{Symbol, Any}()
    for field in fields
        field in fieldnames(typeof(s1)) || continue
        field in fieldnames(typeof(s2)) || continue
        if getfield(s1, field) == getfield(s2, field)
            shared[field] = getfield(s1, field)
        end
    end
    s1 = _remove_fields(s1, keys(shared)...)
    s2 = _remove_fields(s2, keys(shared)...)
    return NamedTuple(shared), s1, s2
end

function _different_or_nothing(s1, s2)
    (s1 != s2 || isempty(s1)) && return s1
    typeof(s1) <: Spec ? Spec(nothing) : typeof(s1)(Spec(nothing))
end

layer(specs::ConstrainedSpec...) = layer(specs)
layer(specs) = sum(specs)

###
### Concatenation
###

"""
    hcat(A::AbstractSpec...)
    [spec1 spec2 spec3 ...]
Horizontal concatenation of specs.
"""
Base.hcat(A::VegaLiteSpec...) = VegaLiteSpec(
    *([i.toplevel for i in A]...),
    hcat([i.viewspec for i in A]...)
)
Base.hcat(A::ConstrainedSpec...) = hcat(vlspec.(collect(A))...)
Base.hcat(A::ViewableSpec...) = HConcatSpec(hconcat=collect(A))

"""
    vcat(A::AbstractSpec...)
    [spec1; spec2; spec3 ...]
Vertical concatenation of specs.
"""
Base.vcat(A::VegaLiteSpec...) = VegaLiteSpec(
    *([i.toplevel for i in A]...),
    vcat([i.viewspec for i in A]...)
)
Base.vcat(A::ConstrainedSpec...) = vcat(vlspec.(collect(A))...)
Base.vcat(A::ViewableSpec...) = VConcatSpec(vconcat=collect(A))

"""
    hvcat(A::AbstractSpec...)
    [spec1 spec2; spec3 spec4 ...]
General (wrappable) concatenation of specs.
"""
Base.hvcat(rows::Tuple{Vararg{Int}}, A::VegaLiteSpec...) = VegaLiteSpec(
    *([i.toplevel for i in A]...),
    hvcat(rows, [i.viewspec for i in A]...)
)
Base.hvcat(rows::Tuple{Vararg{Int}}, A::ConstrainedSpec...) = hvcat(rows, vlspec.(collect(A))...)
Base.hvcat(rows::Tuple{Vararg{Int}}, A::ViewableSpec...) = ConcatSpec(;concat=collect(A), columns=first(rows))

"""
    concat(A::AbstractSpec...; columns)
"""
concat(A::VegaLiteSpec...; columns=nothing) = VegaLiteSpec(
    *([i.toplevel for i in A]...),
    concat([i.viewspec for i in A]...; columns)
)
concat(A::ConstrainedSpec...; columns=nothing) = concat(vlspec.(collect(A))...; columns)
concat(A::ViewableSpec...; columns=nothing) = ConcatSpec(concat=collect(A); columns)
