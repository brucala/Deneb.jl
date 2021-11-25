###
### Layering
###

function LayerSpec(s::SingleSpec)
    common, data, mark, encoding, width, height, view, projection = collect(
        getfield(s, f) for f in fieldnames(SingleSpec)
    )
    layer = [SingleSpec(; common, mark=mark.mark, view, projection)]
    LayerSpec(;data=data.data, encoding=encoding.encoding, width, height, layer=layer)
end

const SingleOrLayerSpec = Union{SingleSpec, LayerSpec}

function _different_or_nothing(s1, s)
    (s1 != s || isnothing(value(s1))) && return s1
    typeof(s1) === Spec ? Spec(nothing) : typeof(s1)(Spec(nothing))
end

Base.:+(a::SingleSpec, b::SingleSpec) = LayerSpec(a) + b
Base.:+(a::SingleSpec, b::LayerSpec) = b + a
function Base.:+(a::LayerSpec, b::SingleSpec)
    common, data, mark, encoding, width, height, view, projection = collect(
        getfield(b, f) for f in fieldnames(SingleSpec)
    )
    data = _different_or_nothing(data, a.data)
    encoding = _different_or_nothing(encoding, a.encoding)
    width = _different_or_nothing(width, a.width)
    height = _different_or_nothing(height, a.height)
    s = SingleSpec(;common, data=data.data, mark=mark.mark, encoding=encoding.encoding, width, height, view, projection)
    layer = deepcopy(a.layer)
    push!(layer, s)
    LayerSpec(
        a.common,
        a.data,
        a.encoding,
        layer,
        a.width,
        a.height,
        a.view,
        a.projection,
        a.resolve
    )
end

function Base.:+(a::LayerSpec, b::LayerSpec)
    # TODO: smarter so we don't share
    LayerSpec(layer=[a, b])
end
