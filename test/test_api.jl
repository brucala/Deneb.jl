nt = (
    name="chart",
    data=3,
    mark=:bar,
    encoding=(
        x=:x,
        y=(field=:y, type=:quantitative)
    )
)

@testset "test spec" begin
    @test spec(nt) == Deneb.Spec(nt)
    @test spec(; nt...) == Deneb.Spec(nt)
end

@testset "test vlspec" begin
    s = Deneb.TopLevelSpec(; nt...)
    @test vlspec(nt) == s
    @test vlspec(; nt...) == s
    @test vlspec(spec(nt)) == s
    @test vlspec(s) == s
end

@testset "test Mark" begin
    @test Mark(a=3) isa Deneb.MarkSpec
    @test value(Mark(a=3).a) == 3
    @test Mark(:bar, tooltip=true) isa Deneb.MarkSpec
    @test value(Mark(:bar, tooltip=true)) == (type="bar", tooltip=true)
end

@testset "test Encoding" begin
    @test Encoding(a=3) isa Deneb.EncodingSpec
    @test value(Encoding(a=3).a) == 3
    @test Encoding("a:q", x=(aggregate="mean",)) isa Deneb.EncodingSpec
    @test value(Encoding("a:q", x=(aggregate="mean",))) == (;
        x = (aggregate = "mean", field = "a", type = "quantitative")
    )
    @test Encoding("a:q", "b:o", x=(aggregate="mean",)) isa Deneb.EncodingSpec
    @test value(Encoding("a:q", "b:o", x=(aggregate="mean",))) == (
        x = (aggregate = "mean", field = "a", type = "quantitative"),
        y=(field = "b", type = "ordinal")
    )
end
