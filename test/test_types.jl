using Deneb: Spec, VegaLiteSpec, specvalue

@testset "Simple Spec" begin
    @test specvalue(Spec(3)) == 3
    @test specvalue(Spec("a")) == "a"
    @test specvalue(Spec(:a)) == "a"
end

nt = (a=1, b=(c="x",))
@testset "NamedTuple Spec" begin
    s = Spec(nt)
    @test s.spec isa NamedTuple
    @test eltype(s.spec) === Spec
    @test specvalue(s) == nt
    @test specvalue(Spec(nt, :a)) == 1
    @test isnothing(specvalue(Spec(nt, :c)))
end

@testset "Vector Spec" begin
    v = [1, nt]
    s = Spec(v)
    @test s.spec isa Vector{Spec}
    @test specvalue(s) == v
    @test s.spec[1].spec == 1
    @test s.spec[2] == Spec(nt)
end

@testset "basic ConstrainedSpec" begin
    s = VegaLiteSpec(; )
    @test s isa Deneb.VegaLiteSpec{Deneb.SingleSpec}
    @test s.toplevel isa Deneb.TopLevelProperties
    @test s.viewspec isa Deneb.SingleSpec
    @test s.viewspec.common isa Deneb.CommonProperties
    @test s.viewspec.data isa Deneb.DataSpec
    @test s.viewspec.encoding isa Deneb.EncodingSpec
    @test s.viewspec.transform isa Deneb.TransformSpec
end

@testset "DataSpec" begin
    d = Deneb.DataSpec(data=3)
    @test d isa Deneb.DataSpec
    @test specvalue(d) == 3
    d = Deneb.DataSpec(data=(a=1:2, b='a':'b'))
    @test d isa Deneb.DataSpec
    @test propertynames(d) == (:values,)
    @test d.values isa Vector
    @test d.values[1] == (a=1, b='a')
    @test d.values[2] == (a=2, b='b')
end

@testset "TransformSpec" begin
    t = Deneb.TransformSpec(transform=3)
    @test t isa Deneb.TransformSpec
    @test specvalue(t) == [3]
    t = Deneb.TransformSpec(transform=[1, 2])
    @test t isa Deneb.TransformSpec
    @test specvalue(t) == [1, 2]
    t = Deneb.TransformSpec(transform=Spec([1, 2]))
    @test t isa Deneb.TransformSpec
    @test specvalue(t) == [1, 2]
    t = Deneb.TransformSpec(transform=[Spec(1), Spec(2)])
    @test t isa Deneb.TransformSpec
    @test specvalue(t) == [1, 2]
    @test propertynames(t) == tuple()
    t = Deneb.TransformSpec(transform=(;filter="a"))
    @test t isa Deneb.TransformSpec
    @test specvalue(t) == [(;filter="a")]
    t = Deneb.TransformSpec(transform=[(;filter="a")])
    @test t isa Deneb.TransformSpec
    @test specvalue(t) == [(;filter="a")]
    @test propertynames(t) == tuple()
    t = Deneb.TransformSpec(transform=nothing)
    @test specvalue(t) == []
    s = Deneb.Spec(Deneb.TransformSpec(3))
    @test specvalue(s) == [3]
end

# TODO: add tests for MarkSpec, EncodingSpec, ParamsSpec, ...

@testset "isempty" begin
    @test isempty(spec(nothing))
    @test !isempty(spec(1))
    @test isempty(spec(;))
    @test isempty(spec(a=nothing))
    @test !isempty(spec(a=1))
    @test isempty(spec([]))
    @test isempty(spec([nothing]))
    @test !isempty(spec([1]))
end

nt = (name="chart", data=3, transform=[(;filter="a")], mark=:bar, encoding=(x=:x, y=(field=:y, type=:quantitative)))

@testset "Spec properties" begin
    @test propertynames(spec()) == tuple()
    s = Spec(nt)
    @test issetequal(propertynames(s), (:name, :data, :transform, :mark, :encoding))
    @test specvalue(s.name) == "chart"
    @test specvalue(s.data) == 3
    @test specvalue(s.transform) == [(;filter="a")]
    @test specvalue(s.mark) == "bar"
    @test issetequal(propertynames(s.encoding), (:x, :y))
    @test specvalue(s.encoding.x) == "x"
    @test issetequal(propertynames(s.encoding.y), (:field, :type))
    @test specvalue(s.encoding.y.field) == "y"
    @test specvalue(s.encoding.y.type) == "quantitative"
end

@testset "VegaLiteSpec properties" begin
    @test propertynames(vlspec()) == tuple()
    s = VegaLiteSpec(; nt...)
    @test issetequal(propertynames(s), (:name, :data, :transform, :mark, :encoding))
    @test specvalue(s.name) == "chart"
    @test specvalue(s.data) == 3
    @test specvalue(s.transform) == [(;filter="a")]
    @test specvalue(s.mark) == "bar"
    @test issetequal(propertynames(s.encoding), (:x, :y))
    @test specvalue(s.encoding.x) == "x"
    @test issetequal(propertynames(s.encoding.y), (:field, :type))
    @test specvalue(s.encoding.y.field) == "y"
    @test specvalue(s.encoding.y.type) == "quantitative"
end
