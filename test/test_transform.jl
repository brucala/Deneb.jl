@testset "transform_calculate" begin
    @test specvalue(transform_calculate(x="value")) == [(as="x", calculate="value")]
    @test specvalue(transform_calculate(x="v1", y="v2")) == [(as="x", calculate="v1"), (as="y", calculate="v2")]
end

@testset "transform_[join]aggregate" begin
    @test specvalue(transform_aggregate(x="mean(f)", y="count()")) == [(;
        aggregate=[(field="f", op="mean", as="x"), (op="count", as="y")]
    )]
    @test specvalue(transform_aggregate(x="mean(f)", groupby=:g)) == [(;
        aggregate=[(field="f", op="mean", as="x")], groupby=["g"]
    )]
    @test specvalue(transform_aggregate(x="mean(f)", groupby=[:g1, :g2])) == [(;
        aggregate=[(field="f", op="mean", as="x")], groupby=["g1", "g2"]
    )]
    @test specvalue(transform_joinaggregate(x="mean(f)", groupby=:g)) == [(;
        joinaggregate=[(field="f", op="mean", as="x")], groupby=["g"]
    )]
end

@testset "transform_timeunit" begin
    @test specvalue(transform_timeunit(x="month(t)")) == [(
        timeUnit="month", field="t", as="x",
    )]
    @test specvalue(transform_timeunit(:x, :t, (unit=:minutes, step=5))) == [(
        timeUnit=(unit="minutes", step=5), field="t", as="x",
    )]
end

# TODO: add tests for other transforms
