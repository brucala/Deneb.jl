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

function _different_or_nothing(s1, s)
    (s1 != s || isnothing(value(s1))) && return s1
    typeof(s1) === Spec ? Spec(nothing) : typeof(s1)(Spec(nothing))
end

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
