@testset "test spec composition" begin
    @test spec(a=3) * spec(b=1) == spec(a=3, b=1)
    @test spec(a=3) * spec(a=1) == spec(a=1)
    @test spec(a=(;b=1, c=2)) * spec(a=(b=2, d=3)) == spec(a=(b=2, c=2, d=3))
end

@testset "test vlspec composition" begin
    @test vlspec(title=2, mark=:bar) * vlspec(name="a", mark=:line) == vlspec(title=2, name="a", mark=:line)
    @test Data(3) * Encoding(:a, :b) * Mark(:bar) isa Deneb.TopLevelSpec
    @test value(Data(3) * Encoding(:a, :b) * Mark(:bar) * Encoding("c:q")) == (
        data = 3,
        mark = (; type = "bar"),
        encoding = (
            x = (field = "c", type = "quantitative"),
            y = (; field = "b")
        )
    )
end

@testset "test layering" begin

    @testset "LayerSpec from SingleSpec" begin
        s = (data=1, width=2, height=3, encoding=:e, mark=:bar, name=:n, view=:v, projection=:p)
        l = Deneb.LayerSpec(Deneb.SingleSpec(;s...))
        @test l isa Deneb.LayerSpec
        @test value(l.data) == 1
        @test value(l.width) == 2
        @test value(l.height) == 3
        @test isempty(l.encoding)
        @test isempty(l.common)
        @test isempty(l.view)
        @test isempty(l.projection)
        @test l.layer isa Vector
        @test length(l.layer) == 1
        @test value(l.layer[1].mark) == "bar"
        @test value(l.layer[1].encoding) == "e"
        @test value(l.layer[1].name) == "n"
        @test value(l.layer[1].view) == "v"
        @test value(l.layer[1].projection) == "p"
    end

    @testset "layer SingleSpec" begin
        l = vlspec(data=1, width=100, mark=:bar) + vlspec(data=1, width=100, mark=:line)
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.data) == 1
        @test value(l.width) == 100
        @test length(l.layer) == 2
        @test value(l.layer[1]) == (;mark="bar")
        @test value(l.layer[2]) == (; mark="line")
        l = vlspec(data=1, width=100, mark=:bar) + vlspec(data=2, width=100, mark=:line)
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.data) == 1
        @test value(l.width) == 100
        @test length(l.layer) == 2
        @test value(l.layer[1]) == (;mark="bar")
        @test l.layer[2] isa Deneb.LayerSpec
        @test value(l.layer[2].data) == 2
        @test value(l.layer[2].layer) == [(; mark="line")]
    end
    @testset "layer LayerSpecs" begin
        l1 = vlspec(data=1, mark=:bar) + vlspec(mark=:line)
        l2 = vlspec(mark=:rule) + vlspec(mark=:point)
        l = l1 + l2
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.data) == 1
        @test length(l.layer) == 4
        @test value(l.layer[1]) == (;mark="bar")
        @test value(l.layer[2]) == (; mark="line")
        @test value(l.layer[3]) == (;mark="rule")
        @test value(l.layer[4]) == (; mark="point")
        l3 = vlspec(data=2) * l2
        l = l1 + l3
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.data) == 1
        @test length(l.layer) == 3
        @test value(l.layer[1]) == (;mark="bar")
        @test value(l.layer[2]) == (; mark="line")
        @test l.layer[3] isa Deneb.LayerSpec
        @test value(l.layer[3].layer[1]) == (; mark="rule")
        @test value(l.layer[3].layer[2]) == (; mark="point")
    end
    @testset "composition with layer" begin
        l = vlspec(data=1, mark=:bar) + vlspec(data=2, mark=:line)
        cl = vlspec(data=3) * l
        @test cl isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(cl.data) == 3
        @test value(cl.layer[1].data) === nothing
        @test value(cl.layer[2].data) == 2
        @test value(cl.layer[2].layer[1].data) === nothing
        cl = l * vlspec(data=3)
        @test cl isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(cl.data) == 1
        @test value(cl.layer[1].data) == 3
        @test value(cl.layer[2].data) == 2
        @test value(cl.layer[2].layer[1].data) == 3
    end

end

@testset "test concatenation" begin
    a, b, c, d = vlspec(mark=:bar), vlspec(mark=:line), vlspec(mark=:point), vlspec(mark=:rule)
    s = [a b]
    @test s isa Deneb.TopLevelSpec{Deneb.HConcatSpec}
    @test length(s.hconcat) == 2
    @test value(s.hconcat[1].mark) == "bar"
    @test value(s.hconcat[2].mark) == "line"
    s = [a; b]
    @test s isa Deneb.TopLevelSpec{Deneb.VConcatSpec}
    @test length(s.vconcat) == 2
    @test value(s.vconcat[1].mark) == "bar"
    @test value(s.vconcat[2].mark) == "line"
    s = [a b; c d]
    @test s isa Deneb.TopLevelSpec{Deneb.ConcatSpec}
    @test length(s.concat) == 4
    @test value(s.columns) == 2
    @test value(s.concat[1].mark) == "bar"
    @test value(s.concat[2].mark) == "line"
    @test value(s.concat[3].mark) == "point"
    @test value(s.concat[4].mark) == "rule"
end
