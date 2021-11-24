using Deneb
using Deneb: value
using Test

@testset "Simple Spec" begin
    @test value(spec(3)) == 3
    @test value(spec("a")) == "a"
    @test value(spec(:a)) == "a"
end

nt = (a=1, b=(c="x",))
@testset "NamedTuple Spec" begin
    s = spec(nt)
    @test s.spec isa NamedTuple
    @test eltype(s.spec) === Deneb.Spec
    @test value(s) == nt
    @test value(Deneb.Spec(nt, :a)) == 1
    @test isnothing(value(Deneb.Spec(nt, :c)))
end

@testset "Vector Spec" begin
    v = [1, nt]
    s = spec(v)
    @test s.spec isa Vector{Deneb.Spec}
    @test value(s) == v
    @test s.spec[1].spec == 1
    @test s.spec[2] == Deneb.Spec(nt)
end

@testset "basic vlspec" begin
    s = vlspec()
    @test vlspec() isa Deneb.TopLevelSpec{Deneb.SingleSpec}
    @test s.toplevel isa Deneb.TopLevelProperties
    @test s.spec isa Deneb.SingleSpec
    @test s.spec.common isa Deneb.CommonProperties
    @test s.spec.data isa Deneb.DataSpec
    @test s.spec.encoding isa Deneb.EncodingSpec
end

nt = (name="chart", data=3, mark=:bar, encoding=(x=:x, y=(field=:y, type=:quantitative)))

@testset "Spec properties" begin
    s = spec(nt)
    @test s == spec(; nt...)
    @test value(s.name) == "chart"
    @test value(s.data) == 3
    @test value(s.mark) == "bar"
    @test value(s.encoding.x) == "x"
    @test value(s.encoding.y.field) == "y"
    @test value(s.encoding.y.type) == "quantitative"
end

@testset "TopLevelSpec properties" begin
    s = vlspec(spec_nt)
    @test s == vlspec(; spec_nt...)
    @test s == vlspec(spec(spec_nt))
    @test value(s.name) == "chart"
    @test value(s.data) == 3
    @test value(s.mark) == "bar"
    @test value(s.encoding.y.field) == "y"
    @test value(s.encoding.y.type) == "quantitative"
end

s = spec(
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
