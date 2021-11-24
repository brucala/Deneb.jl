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

abstract type PropertiesSpec <: AbstractSpec end
abstract type ViewableSpec <: AbstractSpec end
abstract type MultiViewSpec <: ViewableSpec end
abstract type LayoutSpec <: MultiViewSpec end
abstract type ConcatView <: LayoutSpec end

struct TopLevelProperties <: PropertiesSpec
    schema::Spec
    background::Spec
    padding::Spec
    autosize::Spec
    config::Spec
    usermeta::Spec
end

struct TopLevelSpec{T<:ViewableSpec} <: AbstractSpec
    toplevel::TopLevelProperties
    spec::T
end

struct CommonProperties <: PropertiesSpec
    name::Spec
    description::Spec
    title::Spec
    transform::Spec
    params::Spec
end

struct LayoutProperties <: PropertiesSpec
    align::Spec
    bounds::Spec
    center::Spec
    spacing::Spec
end

struct DataSpec <: AbstractSpec
    data::Spec
    DataSpec(t) = new(Spec(t))
end
Base.convert(::Type{DataSpec}, x::Spec) = DataSpec(x)

struct MarkSpec <: AbstractSpec
    mark::Spec
end
Base.convert(::Type{MarkSpec}, x::Spec) = MarkSpec(x)

struct EncodingSpec <: AbstractSpec
    encoding::Spec
end
Base.convert(::Type{EncodingSpec}, x::Spec) = EncodingSpec(x)

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

struct LayerSpec <: MultiViewSpec
    common:: CommonProperties
    data::DataSpec
    encoding::EncodingSpec
    layer::Union{SingleSpec, LayerSpec}
    width::Spec
    height::Spec
    view::Spec
    projection::Spec
    resolve::Spec
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
    spec::Union{SingleSpec, LayerSpec}  # or can it be any spec
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


function TopLevelSpec(; spec...)
    TopLevelSpec(
        PropertiesSpec(TopLevelProperties; spec...),
        ViewableSpec(; spec...)
    )
end

PropertiesSpec(T::Type{<:PropertiesSpec}; spec...) = T((Spec(spec, f) for f in fieldnames(T))...)

function ViewableSpec(; spec...)
    common = PropertiesSpec(CommonProperties; spec...)
    layout = PropertiesSpec(LayoutProperties; spec...)
    T = _viewtype(spec)
    if T <: LayoutSpec
        T(common, layout, (Spec(spec, f) for f in fieldnames(T) if f ∉ (:common, :layout))...)
    end
    T(common, (Spec(spec, f) for f in fieldnames(T) if f != :common)...)
end

function _viewtype(spec)
    return haskey(spec, :layer) ? LayerSpec :
        haskey(spec, :facet) ? FacetSpec :
        haskey(spec, :repeat) ? RepeatSpec :
        haskey(spec, :concat) ? ConcatSpec :
        haskey(spec, :hconcat) ? HConcatSpec :
        haskey(spec, :vconcat) ? VConcatSpec :
        SingleSpec
end

Base.propertynames(s::T) where T<:AbstractSpec = collect(Iterators.flatten(
    t === Spec ? (f,) : propertynames(getfield(s, f))
    for (f, t) in zip(fieldnames(T), fieldtypes(T))
    if t !== Spec || !isnothing(getfield(s, f).spec)
))

function Base.getproperty(s::T, f::Symbol) where T<:AbstractSpec
    f in fieldnames(T) && fieldtype(T, f) === Spec && return getfield(s, f)
    for field in fieldnames(T)
        child = getfield(s, field)
        f in propertynames(child) && return getproperty(child, f)
    end
    return error("property $f not in spec")
end
