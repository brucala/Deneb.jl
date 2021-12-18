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
If the types of the two specs are different then the result spec will be a TopLevelSpec.
"""
Base.:*(a::Spec, b::Spec) = isnothing(value(b)) ? Spec(a) : Spec(b)
Base.:*(a::Spec, b::ConstrainedSpec) = vlspec(a) * b
Base.:*(a::ConstrainedSpec, b::Spec) = a * vlspec(b)
function Base.:*(a::Spec{NamedTuple}, b::Spec{NamedTuple})
    aspec, bspec = a.spec, b.spec
    properties = propertynames(aspec) ∪ propertynames(bspec)
    new_spec = NamedTuple(
        k => get(aspec, k, Spec(nothing)) * get(bspec, k, Spec(nothing))
        for k in properties
    )
    return Spec(new_spec)
end

Base.:*(a::T, b::T) where {T<:ConstrainedSpec}  = T((getfield(a, f) * getfield(b, f) for f in fieldnames(T))...)
Base.:*(a::TopLevelSpec, b::TopLevelSpec)  = TopLevelSpec((getfield(a, f) * getfield(b, f) for f in fieldnames(TopLevelSpec))...)
Base.:*(a::DataSpec, b::DataSpec) = isnothing(value(b)) ? DataSpec(value(a)) : DataSpec(value(b))
function Base.:*(a::T, b::T) where T <: Union{TransformSpec, ParamsSpec}
    isempty(a) && T(value(b))
    isempty(b) && T(value(a))
    fieldname = first(fieldnames(T))
    field = copy(getfield(a, fieldname))
    for i in getfield(b, fieldname)
        i in field || push!(field, i)
    end
    T(field)
end
Base.:*(a::ConstrainedSpec, b::ConstrainedSpec) = vlspec(a) * vlspec(b)

Base.:*(::LayerSpec, ::LayerSpec) = error("Two layered specs can not be composed.")
function Base.:*(a::SingleSpec, b::LayerSpec)
    # if single spec on the left, compose its properties with the top level properties of layer giving precedence to single spec
    s = SingleSpec(mark=value(a.mark))
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

Base.:*(::ConcatView, ::ConcatView) = error("Two concat specs can not be composed.")
function Base.:*(a::SingleSpec, b::T) where T<:ConcatView
    # if single spec on the left, compose its properties with the top level properties of layer giving precedence to single spec
    s = SingleSpec(
        mark=value(a.mark),
        encoding=value(a.encoding),
        width=value(a.width),
        height=value(a.height),
        view=value(a.view),
        projection=value(a.projection),
    )
    columns = get(value(b), :columns, nothing)
    T(
        b.common * a.common,
        b.transform * a.transform,
        b.params * a.params,
        b.layout,
        b.data * a.data,
        [s * l for l in getfield(b, _concat_key(T))],
        #columns,  #FIXME: ConcatSpec
        b.resolve
    )
end
function Base.:*(a::T, b::SingleSpec) where T<:ConcatView
    # if single spec on the right, compose directly with each layer
    columns = get(value(a), :columns, nothing)
    T(
        a.common,
        a.layout,
        data=a.data,
        [l * b for l in getfield(a, _concat_key(T))],
        #columns,  #FIXME: ConcatSpec
        a.resolve
    )
end
_concat_key(::Type{ConcatSpec}) = :concat
_concat_key(::Type{HConcatSpec}) = :hconcat
_concat_key(::Type{VConcatSpec}) = :vconcat


###
### Layering
###

function LayerSpec(s::SingleSpec)
    common, transform, params, data, mark, encoding, width, height, view, projection = collect(
        getfield(s, f) for f in fieldnames(SingleSpec)
    )
    # Promote data, width and height specs as parent specs
    layer = [SingleSpec(; value(common)..., transform=transform.transform , params=params.params, mark=mark.mark, encoding=encoding.encoding, view, projection)]
    LayerSpec(;data=data.data, width, height, layer=layer)
end

const SingleOrLayerSpec = Union{SingleSpec, LayerSpec}

"""
    spec1::ConstrainedSpec + spec2::ConstrainedSpec
The addition of two specs will produce a new spec with both specs layered.
The order matters as `spec1` will appear below `spec2`.
If the specs contain common data, encoding or size properties, they will be promoted to the
top level specification.
Layering layered specification with shared data/encoding/sizes will append the layers ([s1, s2] + [s3, s4]
-> [s1, s2, s3, s4]), otherwise a nested layer is created ([s1, s2, [s3, s4]]).
Multi-view layout specs (facet, repeat, concat) cannot be layered.
"""
function Base.:+(a::TopLevelSpec, b::TopLevelSpec)
    if _incompatible_toplevels(a.toplevel, b.toplevel)
        @warn "Attempting to layer two specs with incompatible toplevel properties. Will use the toplevel properties from spec `a`..."
    end
    toplevel = b.toplevel * a.toplevel
    TopLevelSpec(toplevel, a.viewspec + b.viewspec)
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
Base.:+(a::SingleSpec, b::SingleSpec) = LayerSpec(a) + LayerSpec(b)
Base.:+(a::SingleSpec, b::LayerSpec) = LayerSpec(a) + b
Base.:+(a::LayerSpec, b::SingleSpec) = a + LayerSpec(b)
function Base.:+(a::LayerSpec, b::LayerSpec)
    common, transform, params, data, encoding, layer, width, height, view, projection, resolve = collect(
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
    blayer = LayerSpec(;value(common)..., data=data.data, transform=transform.transform, params=params.params, encoding=encoding.encoding, layer, width, height, view, projection, resolve)
    if isnothing(data.data) && isnothing(value(encoding.encoding)) && isnothing(value(width)) && isnothing(value(height))
        append!(alayer, blayer.layer)
    else
        push!(alayer, blayer)
    end
    LayerSpec(
        a.common,
        a.transform,
        a.params,
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
    typeof(s1) <: Spec ? Spec(nothing) : typeof(s1)(Spec(nothing))
end

###
### Concatenation
###

"""
    hcat(A::AbstractSpec...)
    [spec1 spec2 spec3 ...]
Horizontal concatenation of specs.
"""
Base.hcat(A::TopLevelSpec...) = TopLevelSpec(
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
Base.vcat(A::TopLevelSpec...) = TopLevelSpec(
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
Base.hvcat(rows::Tuple{Vararg{Int}}, A::TopLevelSpec...) = TopLevelSpec(
    *([i.toplevel for i in A]...),
    hvcat(rows, [i.viewspec for i in A]...)
)
Base.hvcat(rows::Tuple{Vararg{Int}}, A::ConstrainedSpec...) = hvcat(rows, vlspec.(collect(A))...)
Base.hvcat(rows::Tuple{Vararg{Int}}, A::ViewableSpec...) = ConcatSpec(concat=collect(A), columns=first(rows))
