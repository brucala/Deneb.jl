module Deneb

using UUIDs
using NodeJS_16_jll
using JSON, Tables
using MultilineStrings: indent

include("types.jl")
include("api.jl")
include("render.jl")
include("composition.jl")
include("themes.jl")

export spec, vlspec,
    Data, Mark, Encoding, field,
    save,
    set_theme!, print_theme

end # module
