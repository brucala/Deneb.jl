module Deneb

using JSON, Tables
using MultilineStrings: indent

include("types.jl")
include("api.jl")
include("render.jl")

export spec, vlspec,
    Data, Mark, Encoding

end # module
