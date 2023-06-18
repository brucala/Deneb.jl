using Deneb
using Test

@testset "Deneb.jl tests" begin
    include("test_types.jl")
    include("test_api.jl")
    include("test_transform.jl")
    include("test_params.jl")
    include("test_composition.jl")
    include("test_render.jl")
    include("test_themes.jl")
end
