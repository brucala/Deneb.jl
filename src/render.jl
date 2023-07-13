JSON.json(s::AbstractSpec) = json(rawspec(s))
JSON.json(s::AbstractSpec, indent) = json(rawspec(s), indent)
JSON.json(s::VegaLiteSpec) = json(rawspec(themespec() * s))
JSON.json(s::VegaLiteSpec, indent) = json(rawspec(themespec() * s), indent)

Base.show(io::IO, s::AbstractSpec) = print(io, json(s, 2))

Base.show(io::IO, ::MIME"text/plain", s::AbstractSpec) = print(io, "$(typeof(s)): \n", s)

Base.show(io::IO, ::MIME"application/json", s::AbstractSpec) = show(io, s)

# VSCode and Jupyter lab display (and defaults to) this MIME type
Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vegalite.v5+json")}) = true
function Base.show(io::IO, ::MIME"application/vnd.vegalite.v5+json", s::VegaLiteSpec)
    print(io, json(s))
end

function Base.show(io::IO, ::MIME"image/png", s::VegaLiteSpec)
    print(io, convert(s, :png))
end

function Base.show(io::IO, ::MIME"image/svg+xml", s::VegaLiteSpec)
    print(io, convert(s, :svg))
end

function Base.show(io::IO, ::MIME"application/pdf", s::VegaLiteSpec)
    print(io, convert(s, :pdf))
end

Base.showable(mime::Union{MIME"application/vnd.vegalite.v5+json"}, s::VegaLiteSpec) = showable(s, mime)
Base.showable(
    mime::Union{MIME"application/pdf", MIME"image/svg+xml", MIME"image/png"},
    s::VegaLiteSpec
) = showable(s, mime, true)

# TODO: Ideally this method would validate the json
function showable(s::VegaLiteSpec, mime, suppress_warn=false)
    required = (:mark, :layer, :facet, :hconcat, :vconcat, :concat, :repeat)
    if isempty(required ∩ propertynames(s))
        suppress_warn || @warn """Spec isn't showable by MIME $mime. Make sure the specification includes at least one of the following properties: "mark", "layer", "facet", "hconcat", "vconcat", "concat", or "repeat"."""
        return false
    end
    return true
end

convert(s::AbstractSpec, fmt::Symbol) = read(
    pipeline(vl2command(fmt), stdin=IOBuffer(json(s))),
    String
)
function vl2command(fmt::Symbol)
    fmt == :vega && (fmt = :vg)
    valid_formats = (:vg, :png, :svg, :pdf)
    Symbol(fmt) ∉ valid_formats && return @warn("Format must be any of $valid_formats")
    deps = ["--yes", "-p", "vega", "-p", "vega-lite"]
    fmt == :vg || append!(deps, ["-p", "canvas"])
    Cmd(`$(node()) $npx $deps vl2$fmt`)
end

# Pluto displays this MIME type
function Base.show(io::IO, ::MIME"text/html",  s::VegaLiteSpec)
    print(io, html(s))
end

html_div(spec, div="vis-"*string(uuid4())) = """
<div id="$div"></div>

<script type="text/javascript">
var spec = $(json(spec));
var embedOpt = {'mode': 'vega-lite'};
function showError(el, error){
    el.innerHTML = ('<div class="error" style="color:red;">'
                    + '<p>JavaScript Error: ' + error.message + '</p>'
                    + "<p>This usually means there's a typo in your chart specification. "
                    + "See the javascript console for the full traceback.</p>"
                    + '</div>');
    throw error;
}
const el = document.getElementById('$div');
vegaEmbed('#$div', spec, embedOpt).catch(error => showError(el, error));
</script>"""

function html_full(spec;
    div="vis-"*string(uuid4()),
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
    $(indent(html_div(spec, div), 4))
    </body>
    </html>
    """
end

html(spec;
    fullhtml=true,
    div="vis-"*string(uuid4()),
    vega_version=5,
    vegalite_version=5,
    vegaembed_version=6,
) = fullhtml ? html_full(spec; div, vega_version, vegalite_version, vegaembed_version) : html_div(spec, div)

###
### Save
###
function save(filename::AbstractString, mime::AbstractString, s::AbstractSpec)
    showable(s, mime) || return
    open(filename, "w") do f
        show(f, mime, s)
    end
end

function save(filename::AbstractString, s::AbstractSpec)
    file_ext = lowercase(splitext(filename)[2])
    if file_ext == ".svg"
        mime = "image/svg+xml"
    elseif file_ext == ".pdf"
        mime = "application/pdf"
    elseif file_ext == ".png"
        mime = "image/png"
    elseif file_ext == ".json"
        mime = "application/json"
    elseif file_ext == ".html"
        mime = "text/html"
    else
        throw(ArgumentError("Unknown file type."))
    end
    save(filename, mime, s)
end
