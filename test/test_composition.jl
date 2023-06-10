@testset "test composition" begin

    @testset "spec composition" begin
        @test spec(a=3) * spec(b=1) == spec(a=3, b=1)
        @test spec(a=3) * spec(a=1) == spec(a=1)
        @test spec(a=(;b=1, c=2)) * spec(a=(b=2, d=3)) == spec(a=(b=2, c=2, d=3))
    end

    @testset "constrained spec composition" begin
        @test vlspec(title=2, mark=:bar) * vlspec(name="a", mark=:line) == vlspec(title=2, name="a", mark=:line)
        composed_spec = Data(3) * Encoding(:a, :b) * Mark(:bar)
        @test composed_spec isa Deneb.TopLevelSpec
        @test value(composed_spec) == (
            data = 3,
            mark = (; type = "bar"),
            encoding = (
                x = (; field = "a"),
                y = (; field = "b")
            )
        )
        @test value(composed_spec * Encoding("c:q")) == (
            data = 3,
            mark = (; type = "bar"),
            encoding = (
                x = (field = "c", type = "quantitative"),
                y = (; field = "b")
            )
        )
    end

    @testset "compose Transform/Params" begin
        @test Deneb.TransformSpec([1, 2]) * Deneb.TransformSpec([2,3]) == Deneb.TransformSpec([1,2,3])
        @test Deneb.ParamsSpec([1, 2]) * Deneb.ParamsSpec([2,3]) == Deneb.ParamsSpec([1,2,3])
        t = Transform(fold=:a, as=[:b, :c])
        @test t * t == t
        p = Params(name=:p, value=5)
        @test p * p == p
        composed_spec = t * p * Mark(:m)
        @test value(composed_spec) == (
            transform = [(fold="a", as=["b", "c"])],
            params = [(name="p", value=5)],
            mark = (; type="m"),
        )
        composed_spec = t * p * Facet(:f)
        @test value(composed_spec) == (
            spec=(
                transform = [(fold="a", as=["b", "c"])],
                params = [(name="p", value=5)],
            ),
            facet = (; field="f"),
        )
    end

end

@testset "test layering" begin

    #@testset "LayerSpec from SingleSpec" begin
    #    s = (data=1, width=2, height=3, encoding=:e, mark=:bar, name=:n, view=:v, projection=:p)
    #    l = Deneb.LayerSpec(Deneb.SingleSpec(;s...))
    #    @test l isa Deneb.LayerSpec
    #    @test value(l.data) == 1
    #    @test value(l.width) == 2
    #    @test value(l.height) == 3
    #    @test isempty(l.encoding)
    #    @test isempty(l.common)
    #    @test isempty(l.view)
    #    @test isempty(l.projection)
    #    @test l.layer isa Vector
    #    @test length(l.layer) == 1
    #    @test value(l.layer[1].mark) == "bar"
    #    @test value(l.layer[1].encoding) == "e"
    #    @test value(l.layer[1].name) == "n"
    #    @test value(l.layer[1].view) == "v"
    #    @test value(l.layer[1].projection) == "p"
    #end
    @testset "layer SingleSpecs" begin
        s1 = vlspec(data=1, width=100, mark=:bar, encoding=:a)
        l = s1 + s1
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.data) == 1
        @test value(l.width) == 100
        @test value(l.encoding) == "a"
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        # mark isn't a field of LayerSpec
        @test value(l.layer[1]) == (; mark="bar")
        @test value(l.layer[2]) == (; mark="bar")
        s2 = vlspec(data=2, width=200, mark=:line, encoding=:b)
        l = s1 + s2
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        # no property was shared between s1 and s2
        @test propertynames(l) == [:layer]
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test value(l.layer[1]) == (data=1, mark="bar", encoding="a", width=100)
        @test value(l.layer[2]) == (data=2, mark="line", encoding="b", width=200)
    end
    @testset "layer SingleSpec + LayerSpec" begin
        s1 = vlspec(data=1, width=100, mark=:bar, encoding=:a)
        s2 = vlspec(data=2, width=100, mark=:line, encoding=:b)
        # all properties are shared
        # final layer with shared properties and layer = [s1, s1, s1]
        l = s1 + s1 + s1
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.data) == 1
        @test value(l.width) == 100
        @test value(l.encoding) == "a"
        @test length(l.layer) == 3
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.SingleSpec
        @test value(l.layer[1]) == (; mark="bar")
        @test value(l.layer[2]) == (; mark="bar")
        @test value(l.layer[3]) == (; mark="bar")
        # all shared properties of layered spec (width) match SingleSpec
        # final layer = [s1, s2, s1]
        l = s1 + (s2 + s1)
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.width) == 100
        @test length(l.layer) == 3
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.SingleSpec
        @test value(l.layer[1]) == (data=1, mark="bar", encoding="a")
        @test value(l.layer[2]) == (data=2, mark="line", encoding="b")
        @test value(l.layer[3]) == (data=1, mark="bar", encoding="a")
        # some shared properties of layered spec (width) don't match SingleSpec
        # final layer = [s1, [s2, s2]]
        l = s1 + (s2 + s2)
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.width) == 100
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.LayerSpec
        @test value(l.layer[1]) == (data=1, mark="bar", encoding="a")
        @test value(l.layer[2].data) == 2
        @test value(l.layer[2].encoding) == "b"
        @test length(l.layer[2].layer) == 2
        @test l.layer[2].layer[1] isa Deneb.SingleSpec
        @test l.layer[2].layer[2] isa Deneb.SingleSpec
        @test value(l.layer[2].layer[1]) == (; mark="line")
        @test value(l.layer[2].layer[2]) == (; mark="line")
    end
    @testset "layer LayerSpecs" begin
        s1 = vlspec(data=1, width=100, mark=:bar, encoding=:a)
        s2 = vlspec(data=2, width=100, mark=:line, encoding=:b)
        # expand all
        l = (s1 + s2) + (s1 + s2)
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.width) == 100
        @test length(l.layer) == 4
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.SingleSpec
        @test l.layer[4] isa Deneb.SingleSpec
        @test value(l.layer[1]) == (data=1, mark="bar", encoding="a")
        @test value(l.layer[2]) == (data=2, mark="line", encoding="b")
        @test value(l.layer[3]) == (data=1, mark="bar", encoding="a")
        @test value(l.layer[4]) == (data=2, mark="line", encoding="b")
        # no expand
        l = (s1 + s1) + (s2 + s2)
        @test l isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(l.width) == 100
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.LayerSpec
        @test l.layer[2] isa Deneb.LayerSpec
        @test value(l.layer[1].data) == 1
        @test value(l.layer[1].encoding) == "a"
        @test length(l.layer[1].layer) == 2
        @test l.layer[2].layer[1] isa Deneb.SingleSpec
        @test l.layer[1].layer[2] isa Deneb.SingleSpec
        @test value(l.layer[1].layer[1]) == (; mark="bar")
        @test value(l.layer[1].layer[2]) == (; mark="bar")
        @test value(l.layer[2].data) == 2
        @test value(l.layer[2].encoding) == "b"
        @test length(l.layer[2].layer) == 2
        @test l.layer[2].layer[1] isa Deneb.SingleSpec
        @test l.layer[2].layer[2] isa Deneb.SingleSpec
        @test value(l.layer[2].layer[1]) == (; mark="line")
        @test value(l.layer[2].layer[2]) == (; mark="line")
        # expand left
        l = (s1 + s2) + (s2 + s2)
        @test value(l.width) == 100
        @test length(l.layer) == 3
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.LayerSpec
        @test length(l.layer[3].layer) == 2
        @test l.layer[3].layer[1] isa Deneb.SingleSpec
        @test l.layer[3].layer[2] isa Deneb.SingleSpec
        # expand right
        l = (s1 + s1) + (s1 + s2)
        @test value(l.width) == 100
        @test length(l.layer) == 3
        @test l.layer[1] isa Deneb.LayerSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.SingleSpec
        @test length(l.layer[1].layer) == 2
        @test l.layer[1].layer[1] isa Deneb.SingleSpec
        @test l.layer[1].layer[2] isa Deneb.SingleSpec
    end
    @testset "composition with layer" begin
        l = vlspec(data=1, mark=:bar) + vlspec(data=2, mark=:line)
        cl = vlspec(data=3) * l
        @test cl isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(cl.data) == 3
        @test value(cl.layer[1].data) == 1
        @test value(cl.layer[2].data) == 2
        cl = l * vlspec(data=3)
        @test cl isa Deneb.TopLevelSpec{Deneb.LayerSpec}
        @test value(cl.layer[1].data) == 3
        @test value(cl.layer[2].data) == 3
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
