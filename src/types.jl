abstract type AbstractSpec end

###
### Spec: arbitrary spec
###

struct Spec{T} <: AbstractSpec
    spec::T
end
Spec(s::Symbol) = Spec(string(s))
Spec(s::NamedTuple) = Spec{NamedTuple}(NamedTuple((k=>Spec(v) for (k,v) in pairs(s))))
Spec(s::Vector) = Spec{Vector{Spec}}([Spec(i) for i in s])
Spec(s::Spec) = Spec(s.spec)
Spec(s, field) = Spec(get(s, field, nothing))

function Spec(s::AbstractSpec)
    Spec(
        NamedTuple(
            property => Spec(getproperty(s, property))
            for property in propertynames(s)
        )
    )
end

Base.:(==)(s1::Spec, s2::Spec) = s1.spec == s2.spec

value(s::Spec) = s.spec
value(s::Spec{NamedTuple}) = NamedTuple((k=>value(v) for (k,v) in pairs(s.spec)))
value(s::Spec{Vector{Spec}}) = [value(v) for v in s.spec]

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

function value(s::ConstrainedSpec)
    NamedTuple(
        p => value(getproperty(s, p))
        for p in propertynames(s)
    )
end
value(v::Vector{T}) where T<:ConstrainedSpec = [value(x) for x in v]

struct TopLevelProperties <: PropertiesSpec
    schema::Spec
    background::Spec
    padding::Spec
    autosize::Spec
    config::Spec
    usermeta::Spec
end
TopLevelProperties(; spec...) = ConstrainedSpec(TopLevelProperties; spec...)

struct TopLevelSpec{T<:ViewableSpec} <: ConstrainedSpec
    toplevel::TopLevelProperties
    viewspec::T
end
TopLevelSpec(; spec...) = ConstrainedSpec(TopLevelSpec; spec...)

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
end
LayoutProperties(; spec...) = ConstrainedSpec(LayoutProperties; spec...)

struct DataSpec <: ConstrainedSpec
    data  # store the original object, not a Spec
end
DataSpec(s::Spec) = DataSpec(value(s))
DataSpec(; data=nothing, kw...) = DataSpec(data)
function value(s::DataSpec)
    if Tables.istable(s.data) && :values ∉ Tables.columnnames(s.data)
        return (values=Tables.rowtable(s.data), )
    end
    s.data
end
struct MarkSpec <: ConstrainedSpec
    mark::Spec
end
MarkSpec(; mark=Spec(nothing), kw...) = MarkSpec(Spec(mark))
value(s::MarkSpec) = value(s.mark)

struct EncodingSpec <: ConstrainedSpec
    encoding::Spec
end
EncodingSpec(; encoding=Spec(nothing), kw...) = EncodingSpec(Spec(encoding))
value(s::EncodingSpec) = value(s.encoding)

struct TransformSpec <: ConstrainedSpec
    transform::Vector{Spec}
    TransformSpec(v::Vector) = new([Spec(i) for i in v if !isempty(Spec(i))])
end
TransformSpec(s::Spec{Vector{Spec}}) = TransformSpec(s.spec)
TransformSpec(s) = TransformSpec([Spec(s)])
TransformSpec(; transform=Spec[], kw...) = TransformSpec(transform)
value(s::TransformSpec) = value.(s.transform)

struct ParamsSpec <: ConstrainedSpec
    params::Vector{Spec}
    ParamsSpec(v::Vector) = new([Spec(i) for i in v if !isempty(Spec(i))])
end
ParamsSpec(s::Spec{Vector{Spec}}) = ParamsSpec(s.spec)
ParamsSpec(s) = ParamsSpec([Spec(s)])
ParamsSpec(; params=Spec[], kw...) = ParamsSpec(params)
value(s::ParamsSpec) = value.(s.params)

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
    resolve::Spec
end
function LayerSpec(; layer, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :layer ? t(; kw...) :
        layer isa Vector ? layer :
        Union{SingleSpec, LayerSpec}[layer]
        for (f, t) in zip(fieldnames(LayerSpec), fieldtypes(LayerSpec))
    )
    LayerSpec(spectuple...)
end

const SingleOrLayerSpec = Union{SingleSpec, LayerSpec}

struct FacetSpec <: LayoutSpec
    common::CommonProperties
    transform::TransformSpec
    params::ParamsSpec
    layout::LayoutProperties
    data::DataSpec
    spec::SingleOrLayerSpec
    facet::Spec
    columns::Spec
    resolve::Spec
end
function FacetSpec(; kw...)
    #haskey(kw, :spec) || error("FacetSpec constructor must contain a `spec` keyword argument")
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
    columns::Spec
    resolve::Spec
end
function RepeatSpec(; kw...)
    #haskey(kw, :spec) || error("RepeatSpec constructor must contain a `spec` keyword argument")
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
    columns::Spec
    resolve::Spec
end
function ConcatSpec(; concat, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :concat ? t(; kw...) :
        concat isa Vector ? concat :
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
    resolve::Spec
end
function HConcatSpec(; hconcat, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :hconcat ? t(; kw...) :
        hconcat isa Vector ? hconcat :
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
    resolve::Spec
end
function VConcatSpec(; vconcat, kw...)
    spectuple = (
        t === Spec ? Spec(kw, f) :
        f !== :vconcat ? t(; kw...) :
        vconcat isa Vector ? vconcat :
        ViewableSpec[vconcat]
        for (f, t) in zip(fieldnames(VConcatSpec), fieldtypes(VConcatSpec))
    )
    VConcatSpec(spectuple...)
end

Base.:(==)(s1::ConstrainedSpec, s2::ConstrainedSpec) = value(s1) == value(s2)

Base.isempty(::Spec) = false
Base.isempty(::Spec{Nothing}) = true
Base.isempty(s::Spec{T}) where T<:Union{NamedTuple, Vector} = isempty(s.spec) || all(isempty, values(s.spec))
Base.isempty(s::DataSpec) = isnothing(value(s))
Base.isempty(s::T) where T<:ConstrainedSpec = all(isempty, [getfield(s, f) for f in fieldnames(T)])

###
### spec properties
###

"""
    propertynames(::AbstractSpec)
Return the parent properties of a specification.
"""
Base.propertynames(s::Spec) = s.spec isa NamedTuple ? propertynames(s.spec) : tuple()
Base.propertynames(d::DataSpec) = isempty(d) ? tuple() : propertynames(value(d))
Base.propertynames(s::MarkSpec) = isempty(s) ? tuple() : propertynames(s.mark)
Base.propertynames(s::EncodingSpec) = isempty(s) ? tuple() : propertynames(s.encoding)
Base.propertynames(::TransformSpec) = tuple()
Base.propertynames(::ParamsSpec) = tuple()
function Base.propertynames(s::T) where T<:AbstractSpec
    isempty(s) && return tuple()
    collect(
        Iterators.flatten(
            t <: Union{Spec, Vector, DataSpec, MarkSpec, EncodingSpec, TransformSpec, ParamsSpec} || f === :spec ? (f,) : propertynames(getfield(s, f))
            for (f, t) in zip(fieldnames(T), fieldtypes(T))
            if !isempty(getfield(s, f))
        )
    )
end

Base.getproperty(s::Spec, i::Symbol) = i in fieldnames(Spec) ? getfield(s, i) : s.spec[i]
Base.getproperty(s::DataSpec, i::Symbol) = i in fieldnames(DataSpec) ? getfield(s, i) : getfield(value(s), i)
function Base.getproperty(s::T, f::Symbol) where T<:AbstractSpec
    f in fieldnames(T) && return getfield(s, f)
    for field in fieldnames(T)
        child = getfield(s, field)
        f in propertynames(child) && return getproperty(child, f)
    end
    return error("property $f not in spec")
end
