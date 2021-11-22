JSON.json(s::AbstractSpec) = json(value(spec(s)))
JSON.json(s::AbstractSpec, indent) = json(value(spec(s)), indent)

Base.show(io::IO, s::AbstractSpec) = print(io, json(s, 2))

Base.show(io::IO, ::MIME"text/plain", s::AbstractSpec) = print(io, "$(typeof(s)): \n", s)

Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vegalite.v4+json")}) = true
function Base.show(io::IO, ::MIME"application/vnd.vegalite.v4+json",  s::Union{TopLevelSpec, Spec})
    print(io, json(s))
end

function Base.show(io::IO, ::MIME"text/html",  s::Union{TopLevelSpec, Spec})
    print(io, html(s))
end

function html(
    spec;
    div=string(hash(rand()), base=16),
    vega_version=5,
    vegalite_version=5,
    vegaembed_version=6,
    )
    """
    <!DOCTYPE html>
    <html>
    <head>
        <script src="https://cdn.jsdelivr.net/npm/vega@$vega_version"></script>
        <script src="https://cdn.jsdelivr.net/npm/vega-lite@$vegalite_version"></script>
        <script src="https://cdn.jsdelivr.net/npm/vega-embed@$vegaembed_version"></script>
    </head>
    <body>
        <div id="vis-$div"></div>

        <script type="text/javascript">
        var spec = $(json(spec));
        vegaEmbed('#vis-$div', spec);
        </script>
    </body>
    </html>
    """
end
