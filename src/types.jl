abstract type AbstractSpec end

###
### Spec: arbitrary spec
###

struct Spec{T} <: AbstractSpec
    spec::T
end
Spec(s::SymbolOrString) = Spec{String}(string(s))
Spec(s::Union{NamedTuple, AbstractDict}) = Spec{NamedTuple}(NamedTuple((Symbol(k)=>Spec(v) for (k,v) in pairs(s))))
Spec(s::Vector) = Spec{Vector{Spec}}([Spec(i) for i in s])
Spec(s::Spec) = Spec(s.spec)
Spec(s, field) = Spec(get(s, field, nothing))
Spec(s::AbstractSpec) = Spec(rawspec(s))

Base.:(==)(s1::Spec, s2::Spec) = s1.spec == s2.spec

rawspec(s::Spec) = s.spec
rawspec(s::Spec{NamedTuple}) = NamedTuple((k=>rawspec(v) for (k,v) in pairs(s.spec)))
rawspec(s::Spec{Vector{Spec}}) = [rawspec(v) for v in s.spec]

###
### Constrained specs
###

abstract type ConstrainedSpec <: AbstractSpec end
abstract type PropertiesSpec <: ConstrainedSpec end
abstract type ViewableSpec <: ConstrainedSpec end
abstract type MultiViewSpec <: ViewableSpec end
abstract type LayoutSpec <: MultiViewSpec end
abstract type ConcatView <: LayoutSpec end

function ConstrainedSpec(T::Type{<:ConstrainedSpec}; spec...)
    spectuple = (
        t === Spec ? Spec(spec, f) : t(; spec...)
        for (f, t) in zip(fieldnames(T), fieldtypes(T))
    )
    T(spectuple...)
end

ViewableSpec(; spec...) = _viewtype(spec)(; spec...)
function _viewtype(spec)
    return haskey(spec, :layer) ? LayerSpec :
        haskey(spec, :facet) ? FacetSpec :
        haskey(spec, :repeat) ? RepeatSpec :
        haskey(spec, :concat) ? ConcatSpec :
        haskey(spec, :hconcat) ? HConcatSpec :
        haskey(spec, :vconcat) ? VConcatSpec :
        SingleSpec
end

function rawspec(s::ConstrainedSpec)
    NamedTuple(
        p => rawspec(getproperty(s, p))
        for p in propertynames(s)
    )
end
rawspec(v::Vector{T}) where T<:ConstrainedSpec = [rawspec(x) for x in v]

struct TopLevelProperties <: PropertiesSpec
    schema::Spec
    background::Spec
    padding::Spec
    autosize::Spec
    config::Spec  # TODO: create dedicated type?
    usermeta::Spec
end
TopLevelProperties(; spec...) = ConstrainedSpec(TopLevelProperties; spec...)

struct VegaLiteSpec{T<:ViewableSpec} <: ConstrainedSpec
    toplevel::TopLevelProperties
    viewspec::T
end
VegaLiteSpec(; spec...) = ConstrainedSpec(VegaLiteSpec; spec...)

struct CommonProperties <: PropertiesSpec
    name::Spec
    description::Spec
    title::Spec
end
CommonProperties(; spec...) = ConstrainedSpec(CommonProperties; spec...)

struct LayoutProperties <: PropertiesSpec
    align::Spec
    bounds::Spec
    center::Spec
    spacing::Spec
    columns::Spec
end
LayoutProperties(; spec...) = ConstrainedSpec(LayoutProperties; spec...)

struct DataSpec <: ConstrainedSpec
    data  # store the original object, not a Spec
end
DataSpec(s::Union{Spec, DataSpec}) = DataSpec(rawspec(s))
DataSpec(; data=nothing, kw...) = DataSpec(data)
function rawspec(s::DataSpec)
    Tables.isrowtable(s.data) && return (values=s.data, )
    if (
        Tables.istable(s.data)
        # already in the VegaLite shape
        && !haskey(s.data, :values)
        # data generators
        && !haskey(s.data, :graticule)
        && !haskey(s.data, :sequence)
        && !haskey(s.data, :sphere)
    )
        return (values=Tables.rowtable(s.data), )
    end
    s.data
end
struct MarkSpec <: ConstrainedSpec
    mark::Spec
end
MarkSpec(; mark=Spec(nothing), kw...) = MarkSpec(Spec(mark))
rawspec(s::MarkSpec) = rawspec(s.mark)

struct EncodingSpec <: ConstrainedSpec
    encoding::Spec
end
EncodingSpec(; encoding=Spec(nothing), kw...) = EncodingSpec(Spec(encoding))
rawspec(s::EncodingSpec) = rawspec(s.encoding)

struct TransformSpec <: ConstrainedSpec
    transform::Spec{<:Vector}
    TransformSpec(s::Spec{<:Vector}) = new(Spec([i for i in s.spec if !isempty(i)]))
end
TransformSpec(s::Spec) = TransformSpec(Spec([s]))
TransformSpec(s) = TransformSpec(Spec(s))
TransformSpec(; transform=Spec([]), kw...) = TransformSpec(transform)
rawspec(s::TransformSpec) = rawspec(s.transform)

# TODO: parameters are named with a unique "name" property required
# TODO: imposed named params and implement composition logic with unique names
struct ParamsSpec <: ConstrainedSpec
    params::Spec{<:Vector}
    ParamsSpec(s::Spec{<:Vector}) = new(Spec([i for i in s.spec if !isempty(i)]))
end
ParamsSpec(s::Spec) = ParamsSpec(Spec([s]))
ParamsSpec(s) = ParamsSpec(Spec(s))
ParamsSpec(; params=Spec([]), kw...) = ParamsSpec(params)
rawspec(s::ParamsSpec) = rawspec(s.params)

struct SingleSpec <: ViewableSpec
    common::CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    data::DataSpec
    mark::MarkSpec
    encoding::EncodingSpec
    width::Spec
    height::Spec
    view::Spec
    projection::Spec
end
SingleSpec(; spec...) = ConstrainedSpec(SingleSpec; spec...)

struct ResolveSpec <: ConstrainedSpec
    resolve::Spec
end
ResolveSpec(; resolve=Spec(nothing), kw...) = ResolveSpec(Spec(resolve))
rawspec(s::ResolveSpec) = rawspec(s.resolve)

struct LayerSpec <: MultiViewSpec
    common:: CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    data::DataSpec
    encoding::EncodingSpec
    layer::Vector{Union{SingleSpec, LayerSpec}}
    width::Spec
    height::Spec
    view::Spec
    projection::Spec
    resolve::ResolveSpec
end

const SingleOrLayerSpec = Union{SingleSpec, LayerSpec}

SingleOrLayerSpec(s::NamedTuple) = haskey(s, :layer) ? LayerSpec(; s...) : SingleSpec(; s...)

function LayerSpec(; layer, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :layer ? t(; kw...) :
        _layer(layer)
        for (f, t) in zip(fieldnames(LayerSpec), fieldtypes(LayerSpec))
    )
    LayerSpec(spectuple...)
end

_layer(l::Vector{<:SingleOrLayerSpec}) = l
_layer(l::Vector{<:NamedTuple}) = [SingleOrLayerSpec(s) for s in l]
_layer(l) = SingleOrLayerSpec[l]

struct FacetSpec <: LayoutSpec
    common::CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    layout::LayoutProperties
    data::DataSpec
    spec::SingleOrLayerSpec
    facet::Spec
    resolve::ResolveSpec
end
function FacetSpec(; kw...)
    haskey(kw, :facet) || error("FacetSpec constructor must contain a `facet` keyword argument")
    spec = get(kw, :spec, SingleSpec())
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :spec ? t(; kw...) :
        spec isa SingleOrLayerSpec ? spec :
        ViewableSpec(;spec...)
        for (f, t) in zip(fieldnames(FacetSpec), fieldtypes(FacetSpec))
    )
    FacetSpec(spectuple...)
end

struct RepeatSpec <: LayoutSpec
    common:: CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    layout::LayoutProperties
    data::DataSpec
    spec::SingleOrLayerSpec  # or can it be any ViewableSpec?
    repeat::Spec
    resolve::ResolveSpec
end
function RepeatSpec(; kw...)
    haskey(kw, :repeat) || error("RepeatSpec constructor must contain a `repeat` keyword argument")
    spec = get(kw, :spec, SingleSpec())
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :spec ? t(; kw...) :
        spec isa SingleOrLayerSpec ? spec :
        ViewableSpec(;spec...)
        for (f, t) in zip(fieldnames(RepeatSpec), fieldtypes(RepeatSpec))
    )
    RepeatSpec(spectuple...)
end

struct ConcatSpec <: ConcatView
    common:: CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    layout::LayoutProperties
    data::DataSpec
    concat::Vector{ViewableSpec}
    resolve::ResolveSpec
end
function ConcatSpec(; concat, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :concat ? t(; kw...) :
        concat isa Vector{<:ViewableSpec} ? concat :
        concat isa Vector{<:NamedTuple} ? [ViewableSpec(; s...) for s in concat] :
        ViewableSpec[concat]
        for (f, t) in zip(fieldnames(ConcatSpec), fieldtypes(ConcatSpec))
    )
    ConcatSpec(spectuple...)
end

struct HConcatSpec <: ConcatView
    common:: CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    layout::LayoutProperties
    data::DataSpec
    hconcat::Vector{ViewableSpec}
    resolve::ResolveSpec
end
function HConcatSpec(; hconcat, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :hconcat ? t(; kw...) :
        hconcat isa Vector{<:ViewableSpec} ? hconcat :
        hconcat isa Vector{<:NamedTuple} ? [ViewableSpec(; s...) for s in hconcat] :
        ViewableSpec[hconcat]
        for (f, t) in zip(fieldnames(HConcatSpec), fieldtypes(HConcatSpec))
    )
    HConcatSpec(spectuple...)
end

struct VConcatSpec <: ConcatView
    common:: CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    layout::LayoutProperties
    data::DataSpec
    vconcat::Vector{ViewableSpec}
    resolve::ResolveSpec
end
function VConcatSpec(; vconcat, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :vconcat ? t(; kw...) :
        vconcat isa Vector{<:ViewableSpec} ? vconcat :
        vconcat isa Vector{<:NamedTuple} ? [ViewableSpec(; s...) for s in vconcat] :
        ViewableSpec[vconcat]
        for (f, t) in zip(fieldnames(VConcatSpec), fieldtypes(VConcatSpec))
    )
    VConcatSpec(spectuple...)
end

Base.:(==)(s1::ConstrainedSpec, s2::ConstrainedSpec) = rawspec(s1) == rawspec(s2)

Base.isempty(::Spec) = false
Base.isempty(::Spec{Nothing}) = true
Base.isempty(s::Spec{T}) where T<:Union{NamedTuple, Vector} = isempty(s.spec) || all(isempty, values(s.spec))
Base.isempty(s::DataSpec) = isnothing(rawspec(s))
Base.isempty(s::T) where T<:ConstrainedSpec = all(isempty, [getfield(s, f) for f in fieldnames(T)])

###
### spec properties
###

"""
    propertynames(::AbstractSpec)
Return the parent properties of a specification.
"""
Base.propertynames(s::Spec) = s.spec isa NamedTuple ? propertynames(s.spec) : tuple()
Base.propertynames(d::DataSpec) = isempty(d) ? tuple() : propertynames(rawspec(d))
Base.propertynames(s::MarkSpec) = isempty(s) ? tuple() : propertynames(s.mark)
Base.propertynames(s::ResolveSpec) = isempty(s) ? tuple() : propertynames(s.resolve)
Base.propertynames(s::EncodingSpec) = isempty(s) ? tuple() : propertynames(s.encoding)
Base.propertynames(::TransformSpec) = tuple()
Base.propertynames(::ParamsSpec) = tuple()
function Base.propertynames(s::T) where T<:AbstractSpec
    isempty(s) && return tuple()
    collect(
        Iterators.flatten(
            !(t <: Union{ViewableSpec, PropertiesSpec}) || f === :spec ? (f,) : propertynames(getfield(s, f))
            for (f, t) in zip(fieldnames(T), fieldtypes(T))
            if !isempty(getfield(s, f))
        )
    )
end

Base.getproperty(s::Spec, i::Symbol) = i in fieldnames(Spec) ? getfield(s, i) : s.spec[i]
Base.getproperty(s::DataSpec, i::Symbol) = i in fieldnames(DataSpec) ? getfield(s, i) : getfield(rawspec(s), i)
function Base.getproperty(s::T, f::Symbol) where T<:AbstractSpec
    f in fieldnames(T) && return getfield(s, f)
    for field in fieldnames(T)
        child = getfield(s, field)
        f in propertynames(child) && return getproperty(child, f)
    end
    return error("property $f not in spec")
end
