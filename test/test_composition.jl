@testset "test composition" begin

    @testset "spec composition" begin
        @test spec(a=3) * spec(b=1) == spec(a=3, b=1)
        @test spec(a=3) * spec(a=1) == spec(a=1)
        @test spec(a=(;b=1, c=2)) * spec(a=(b=2, d=3)) == spec(a=(b=2, c=2, d=3))
    end

    @testset "constrained spec composition" begin
        @test vlspec(title=2, mark=:bar) * vlspec(name="a", mark=:line) == vlspec(title=2, name="a", mark=:line)
        composed_spec = Data(3) * Encoding(:a, :b) * Mark(:bar)
        @test composed_spec isa Deneb.VegaLiteSpec
        @test specvalue(composed_spec) == (
            data = 3,
            mark = (; type = "bar"),
            encoding = (
                x = (; field = "a"),
                y = (; field = "b")
            )
        )
        @test specvalue(composed_spec * Encoding("c:q")) == (
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
        @test specvalue(composed_spec) == (
            transform = [(fold="a", as=["b", "c"])],
            params = [(name="p", value=5)],
            mark = (; type="m"),
        )
        composed_spec = t * p * Facet(:f)
        @test specvalue(composed_spec) == (
            transform = [(fold="a", as=["b", "c"])],
            params = [(name="p", value=5)],
            facet = (; field="f"),
        )
        composed_spec = Facet(:f) * t * p
        @test specvalue(composed_spec) == (
            spec=(
                transform = [(fold="a", as=["b", "c"])],
                params = [(name="p", value=5)],
            ),
            facet = (; field="f"),
        )
    end

end

@testset "test layering" begin
    @testset "layer SingleSpecs" begin
        s1 = vlspec(data=1, width=100, mark=:bar, encoding=:a)
        l = s1 + s1
        @test l isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(l.data) == 1
        @test specvalue(l.width) == 100
        @test specvalue(l.encoding) == "a"
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        # mark isn't a field of LayerSpec
        @test specvalue(l.layer[1]) == (; mark="bar")
        @test specvalue(l.layer[2]) == (; mark="bar")
        s2 = vlspec(data=2, width=200, mark=:line, encoding=:b)
        l = s1 + s2
        @test l isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        # no property was shared between s1 and s2
        @test propertynames(l) == [:layer]
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test specvalue(l.layer[1]) == (data=1, mark="bar", encoding="a", width=100)
        @test specvalue(l.layer[2]) == (data=2, mark="line", encoding="b", width=200)
    end
    @testset "layer SingleSpec + LayerSpec" begin
        s1 = vlspec(data=1, width=100, mark=:bar, encoding=:a)
        s2 = vlspec(data=2, width=100, mark=:line, encoding=:b)
        # all properties are shared
        # final layer with shared properties and layer = [s1, s1, s1]
        l = s1 + s1 + s1
        @test l isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(l.data) == 1
        @test specvalue(l.width) == 100
        @test specvalue(l.encoding) == "a"
        @test length(l.layer) == 3
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.SingleSpec
        @test specvalue(l.layer[1]) == (; mark="bar")
        @test specvalue(l.layer[2]) == (; mark="bar")
        @test specvalue(l.layer[3]) == (; mark="bar")
        # all shared properties of layered spec (width) match SingleSpec
        # final layer = [s1, s2, s1]
        l = s1 + (s2 + s1)
        @test l isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(l.width) == 100
        @test length(l.layer) == 3
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.SingleSpec
        @test specvalue(l.layer[1]) == (data=1, mark="bar", encoding="a")
        @test specvalue(l.layer[2]) == (data=2, mark="line", encoding="b")
        @test specvalue(l.layer[3]) == (data=1, mark="bar", encoding="a")
        # some shared properties of layered spec (width) don't match SingleSpec
        # final layer = [s1, [s2, s2]]
        l = s1 + (s2 + s2)
        @test l isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(l.width) == 100
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.LayerSpec
        @test specvalue(l.layer[1]) == (data=1, mark="bar", encoding="a")
        @test specvalue(l.layer[2].data) == 2
        @test specvalue(l.layer[2].encoding) == "b"
        @test length(l.layer[2].layer) == 2
        @test l.layer[2].layer[1] isa Deneb.SingleSpec
        @test l.layer[2].layer[2] isa Deneb.SingleSpec
        @test specvalue(l.layer[2].layer[1]) == (; mark="line")
        @test specvalue(l.layer[2].layer[2]) == (; mark="line")
    end
    @testset "layer LayerSpecs" begin
        s1 = vlspec(data=1, width=100, mark=:bar, encoding=:a)
        s2 = vlspec(data=2, width=100, mark=:line, encoding=:b)
        # expand all
        l = (s1 + s2) + (s1 + s2)
        @test l isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(l.width) == 100
        @test length(l.layer) == 4
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.SingleSpec
        @test l.layer[4] isa Deneb.SingleSpec
        @test specvalue(l.layer[1]) == (data=1, mark="bar", encoding="a")
        @test specvalue(l.layer[2]) == (data=2, mark="line", encoding="b")
        @test specvalue(l.layer[3]) == (data=1, mark="bar", encoding="a")
        @test specvalue(l.layer[4]) == (data=2, mark="line", encoding="b")
        # no expand
        l = (s1 + s1) + (s2 + s2)
        @test l isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(l.width) == 100
        @test length(l.layer) == 2
        @test l.layer[1] isa Deneb.LayerSpec
        @test l.layer[2] isa Deneb.LayerSpec
        @test specvalue(l.layer[1].data) == 1
        @test specvalue(l.layer[1].encoding) == "a"
        @test length(l.layer[1].layer) == 2
        @test l.layer[2].layer[1] isa Deneb.SingleSpec
        @test l.layer[1].layer[2] isa Deneb.SingleSpec
        @test specvalue(l.layer[1].layer[1]) == (; mark="bar")
        @test specvalue(l.layer[1].layer[2]) == (; mark="bar")
        @test specvalue(l.layer[2].data) == 2
        @test specvalue(l.layer[2].encoding) == "b"
        @test length(l.layer[2].layer) == 2
        @test l.layer[2].layer[1] isa Deneb.SingleSpec
        @test l.layer[2].layer[2] isa Deneb.SingleSpec
        @test specvalue(l.layer[2].layer[1]) == (; mark="line")
        @test specvalue(l.layer[2].layer[2]) == (; mark="line")
        # expand left
        l = (s1 + s2) + (s2 + s2)
        @test specvalue(l.width) == 100
        @test length(l.layer) == 3
        @test l.layer[1] isa Deneb.SingleSpec
        @test l.layer[2] isa Deneb.SingleSpec
        @test l.layer[3] isa Deneb.LayerSpec
        @test length(l.layer[3].layer) == 2
        @test l.layer[3].layer[1] isa Deneb.SingleSpec
        @test l.layer[3].layer[2] isa Deneb.SingleSpec
        # expand right
        l = (s1 + s1) + (s1 + s2)
        @test specvalue(l.width) == 100
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
        @test cl isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(cl.data) == 3
        @test specvalue(cl.layer[1].data) == 1
        @test specvalue(cl.layer[2].data) == 2
        cl = l * vlspec(data=3)
        @test cl isa Deneb.VegaLiteSpec{Deneb.LayerSpec}
        @test specvalue(cl.layer[1].data) == 3
        @test specvalue(cl.layer[2].data) == 3
    end

end

@testset "test concatenation" begin
    a, b, c, d = vlspec(mark=:bar), vlspec(mark=:line), vlspec(mark=:point), vlspec(mark=:rule)
    s = [a b]
    @test s isa Deneb.VegaLiteSpec{Deneb.HConcatSpec}
    @test length(s.hconcat) == 2
    @test specvalue(s.hconcat[1].mark) == "bar"
    @test specvalue(s.hconcat[2].mark) == "line"
    s = [a; b]
    @test s isa Deneb.VegaLiteSpec{Deneb.VConcatSpec}
    @test length(s.vconcat) == 2
    @test specvalue(s.vconcat[1].mark) == "bar"
    @test specvalue(s.vconcat[2].mark) == "line"
    s = [a b; c d]
    @test s isa Deneb.VegaLiteSpec{Deneb.ConcatSpec}
    @test length(s.concat) == 4
    @test specvalue(s.columns) == 2
    @test specvalue(s.concat[1].mark) == "bar"
    @test specvalue(s.concat[2].mark) == "line"
    @test specvalue(s.concat[3].mark) == "point"
    @test specvalue(s.concat[4].mark) == "rule"
end
