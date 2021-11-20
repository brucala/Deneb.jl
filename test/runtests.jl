using Deneb
using Test

@testset "Simple Spec" begin
    @test spec(3).spec == 3
    @test spec("a").spec == "a"
    @test spec(:a).spec == "a"
end

@testset "NamedTuple Spec" begin
    nt = (a=1, b=(c="x",))
    s = spec(nt)
    @test s.spec isa NamedTuple
    @test eltype(s.spec) === Deneb.Spec
    @test Deneb.Spec(nt, :a).spec == 1
    @test isnothing(Deneb.Spec(nt, :c).spec)
end

@testset "Vector Spec" begin
    v = [1, nt]
    s = spec(v)
    @test s.spec isa Vector{Deneb.Spec}
    @test s.spec[1].spec == 1
    @test s.spec[2] == Deneb.Spec(nt)
end

spec_nt = (name="chart", data=3, mark=:bar, encoding=(x=:x, y=(field=:y, type=:quantitative)))

@testset "Spec properties" begin
    s = spec(spec_nt)
    @test s == spec(; spec_nt...)
    @test s.name.spec == "chart"
    @test s.data.spec == 3
    @test s.mark.spec == "bar"
    @test s.encoding.x.spec == "x"
    @test s.encoding.y.field.spec == "y"
    @test s.encoding.y.type.spec == "quantitative"
end

@testset "TopLevelSpec properties" begin
    chart = vlspec(spec_nt)
    @test chart == vlspec(; spec_nt...)
    @test chart == vlspec(spec(spec_nt))
    @test chart.name.spec == "chart"
    @test chart.data.spec == 3
    @test chart.mark.spec == "bar"
    @test chart.encoding.y.field.spec == "y"
    @test chart.encoding.y.type.spec == "quantitative"
end
