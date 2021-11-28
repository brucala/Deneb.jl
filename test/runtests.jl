using Deneb
using Test

@testset "Deneb.jl tests" begin
    include("test_types.jl")
    include("test_api.jl")
    include("test_composision.jl")
end

s = (
    mark=(type=:bar, tooltip=true),
    encoding=(
        x=(field=:a, type=:nominal),
        y=(field=:b, type=:quantitative)
    ),
    data = (
        values=[
            (a="A", b=28),
            (a="B", b=55),
            (a="C", b=43),
            (a="D", b=91),
            (a="E", b= 81),
            (a="F", b= 53),
            (a="G", b= 19),
            (a="H", b= 87),
            (a="I", b= 52)
        ],
    ),
)

spec(s)
vlspec(s)

data = (a=string.('A':'I'), b=rand(0:100, 9))
Data(data) * Mark(:bar, tooltip=true) * Encoding("a:n", "b:q")
