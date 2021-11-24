module Deneb

using JSON, Tables
using MultilineStrings: indent

include("spec_types.jl")
include("spec_api.jl")
include("render.jl")

export spec, vlspec,
    data, mark, encoding

end # module
