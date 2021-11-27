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

Base.propertynames(s::Spec) = s.spec isa NamedTuple ? propertynames(s.spec) : tuple()
Base.getproperty(s::Spec, i::Symbol) = i in fieldnames(Spec) ? getfield(s, i) : s.spec[i]

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
    spec::T
end
TopLevelSpec(; spec...) = ConstrainedSpec(TopLevelSpec; spec...)

struct CommonProperties <: PropertiesSpec
    name::Spec
    description::Spec
    title::Spec
    transform::Spec
    params::Spec
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

struct SingleSpec <: ViewableSpec
    common:: CommonProperties
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

struct FacetSpec <: LayoutSpec
    common:: CommonProperties
    layout::LayoutProperties
    data::DataSpec
    spec::Union{SingleSpec, LayerSpec}
    facet::Spec
    columns::Spec
    resolve::Spec
end

struct RepeatSpec <: LayoutSpec
    common:: CommonProperties
    layout::LayoutProperties
    data::DataSpec
    spec::Union{SingleSpec, LayerSpec}  # or can it be any ViewableSpec?
    repeat::Spec
    columns::Spec
    resolve::Spec
end

struct ConcatSpec <: ConcatView
    common:: CommonProperties
    layout::LayoutProperties
    data::DataSpec
    concat::Vector{ViewableSpec}
    columns::Spec
    resolve::Spec
end

struct HConcatSpec <: ConcatView
    common:: CommonProperties
    layout::LayoutProperties
    data::DataSpec
    hconcat::Vector{ViewableSpec}
    resolve::Spec
end

struct VConcatSpec <: ConcatView
    common:: CommonProperties
    layout::LayoutProperties
    data::DataSpec
    vconcat::Vector{ViewableSpec}
    resolve::Spec
end

Base.propertynames(d::DataSpec) = isnothing(d.data) ? tuple() : (:data,)
function Base.propertynames(s::T) where T<:AbstractSpec
    collect(
        Iterators.flatten(
            t <: Union{Spec, Vector} ? (f,) : propertynames(getfield(s, f))
            for (f, t) in zip(fieldnames(T), fieldtypes(T))
            if t !== Spec || !isnothing(getfield(s, f).spec)
        )
    )
end

function Base.getproperty(s::T, f::Symbol) where T<:AbstractSpec
    f in fieldnames(T) && return getfield(s, f)
    for field in fieldnames(T)
        child = getfield(s, field)
        f in propertynames(child) && return getproperty(child, f)
    end
    return error("property $f not in spec")
end
