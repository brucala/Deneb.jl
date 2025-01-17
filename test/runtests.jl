using Deneb
using Test

using Deneb: Spec, VegaLiteSpec, rawspec

@testset "Deneb.jl tests" begin
    include("test_types.jl")
    include("test_api.jl")
    include("test_transform.jl")
    include("test_params.jl")
    include("test_composition.jl")
    include("test_render.jl")
    include("test_themes.jl")
    include("test_graphs.jl")
end
