using Documenter, DemoCards, Deneb, UUIDs, JSON

# overload default
function Base.show(io::IO, ::MIME"text/html", s::Deneb.TopLevelSpec)
    divid = string("vl", replace(string(uuid4()), "-" => ""))
    print(io, "<div id='$divid' style=\"width:100%;height:100%;\"></div>")
    print(io, "<script type='text/javascript'>requirejs.config({paths:{'vg-embed': 'https://cdn.jsdelivr.net/npm/vega-embed@6?noext','vega-lib': 'https://cdn.jsdelivr.net/npm/vega-lib?noext','vega-lite': 'https://cdn.jsdelivr.net/npm/vega-lite@5?noext','vega': 'https://cdn.jsdelivr.net/npm/vega@5?noext'}}); require(['vg-embed'],function(vegaEmbed){vegaEmbed('#$divid',")
    print(io, json(s))
    print(io, ",{mode:'vega-lite'}).catch(console.warn);})</script>")
end

gallery, gallery_cb, gallery_assets = makedemos("examples")

assets = []
isnothing(gallery_assets) || push!(assets, gallery_assets)


format = Documenter.HTML(;assets)

makedocs(
    modules=[Deneb],
    sitename="Deneb.jl",
    format=format,
    pages=[
        "Home" => "index.md",
        "Gallery" => gallery,
    ]
)

gallery_cb()
