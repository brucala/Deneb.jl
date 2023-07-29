using Documenter, DemoCards, Deneb, UUIDs

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
            "Interactive Charts" => "interactive.md",
            # "Customization" => "customization.md",
            "Themes" => "themes.md",
            # "Internals" => "internals.md",
        ],
        "Gallery" => gallery,
        "API" => "api.md",
    ],
    strict=true,
)

gallery_cb()

deploydocs(repo="github.com/brucala/Deneb.jl")
