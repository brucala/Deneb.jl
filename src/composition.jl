###
### Layering
###

const SingleOrLayerSpec = Union{SingleSpec, LayerSpec}

# TODO: smarter so commmon properties like data or encoding are shared
Base.:+(a::SingleOrLayerSpec, b::SingleOrLayerSpec) = LayerSpec(layer=[a, b])
