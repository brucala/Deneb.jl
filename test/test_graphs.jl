using Graphs, NetworkLayout

g = wheel_graph(5)

@testset "Graph data" begin
    nodes, edges = graph_data(g)
    @test nodes isa Dict
    @test edges isa Dict
    @test Set(keys(nodes)) == Set([:id, :x, :y])
    @test Set(keys(edges)) == Set([:src, :dst, :x, :x2, :y, :y2, :label])
    @test nodes[:id] == collect(1:5)
    @test edges[:src] == [1, 1, 1, 1, 2, 2, 3, 4]
    @test edges[:dst] == [2, 3, 4, 5, 3, 5, 4, 5]

    nodes, edges = graph_data(g, node_label="abcde", edge_width=1:8)
    @test nodes isa Dict
    @test edges isa Dict
    @test Set(keys(nodes)) == Set([:id, :x, :y, :label])
    @test Set(keys(edges)) == Set([:src, :dst, :x, :x2, :y, :y2, :label, :width])
    @test nodes[:id] == collect(1:5)
    @test nodes[:label] == collect("abcde")
    @test edges[:src] == [1, 1, 1, 1, 2, 2, 3, 4]
    @test edges[:dst] == [2, 3, 4, 5, 3, 5, 4, 5]
    @test edges[:width] == collect(1:8)
end

@testset "Graph Datasets" begin
    ds = Datasets(g, node_label="abcde", edge_width=1:8)
    @test ds isa Deneb.VegaLiteSpec
    @test hasproperty(ds, :datasets)
    @test propertynames(ds.datasets) == (:nodes, :edges)
    nodes = rawspec(ds.datasets.nodes)
    @test nodes isa Vector{<:NamedTuple}
    @test length(nodes) == 5
    @test keys(nodes[1]) == (:id, :y, :label, :x)
    edges = rawspec(ds.datasets.edges)
    @test edges isa Vector{<:NamedTuple}
    @test length(edges) == 8
    @test keys(edges[1]) == ( :width, :src, :dst, :y, :x2, :label, :y2, :x)
end

@testset "plotgraph" begin
    chart = plotgraph(g, node_label="abcde", edge_width=1:8)
    @test chart isa Deneb.VegaLiteSpec
    @test hasproperty(chart, :datasets)
    @test hasproperty(chart, :layer)
    @test length(chart.layer) == 2
end