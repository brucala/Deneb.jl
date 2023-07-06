using Documenter, DemoCards, Deneb, UUIDs

# overload default for a version that can be embeded in the docs
# TODO: this should be done in a smarter way
function Base.show(io::IO, ::MIME"text/html", s::Deneb.VegaLiteSpec)
    divid = string("vl", replace(string(uuid4()), "-" => ""))
    print(io, "<div id='$divid' style=\"width:100%;height:100%;\"></div>")
    print(io, "<script type='text/javascript'>requirejs.config({paths:{'vg-embed': 'https://cdn.jsdelivr.net/npm/vega-embed@6?noext','vega-lib': 'https://cdn.jsdelivr.net/npm/vega-lib?noext','vega-lite': 'https://cdn.jsdelivr.net/npm/vega-lite@5?noext','vega': 'https://cdn.jsdelivr.net/npm/vega@5?noext'}}); require(['vg-embed'],function(vegaEmbed){vegaEmbed('#$divid',")
    print(io, Deneb.json(s))
    print(io, ",{mode:'vega-lite'}).catch(console.warn);})</script>")
end

gallery, gallery_cb, gallery_assets = makedemos("examples")

assets = ["assets/favicon.ico"]
isnothing(gallery_assets) || push!(assets, gallery_assets)


format = Documenter.HTML(;
    assets,
    prettyurls = get(ENV, "CI", nothing) == "true",
)

makedocs(
    modules=[Deneb],
    sitename="Deneb.jl",
    format=format,
    pages=[
        "Home" => "index.md",
        "Getting Started" => [
            "Installation" => "installation.md",
            "Basic Tutorial" => "basic_tutorial.md",
        ],
        "User Guide" => [
            "Introduction" => "intro.md",
            "Data, Mark and Encoding" => "data_mark_encoding.md",
            "Composition and Layering" => "composition_and_layering.md",
            "Multi-views" => "multiview.md",
            # "Customization" => "customization.md",
            "Themes" => "themes.md",
            # "Internals" => "internals.md",
        ],
        "Gallery" => gallery,
        "API" => "api.md",
    ]
)

gallery_cb()

deploydocs(repo="github.com/brucala/Deneb.jl")
