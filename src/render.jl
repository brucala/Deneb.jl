JSON.json(s::AbstractSpec) = json(value(s))
JSON.json(s::AbstractSpec, indent) = json(value(s), indent)

Base.show(io::IO, s::AbstractSpec) = print(io, json(s, 2))

Base.show(io::IO, ::MIME"text/plain", s::AbstractSpec) = print(io, "$(typeof(s)): \n", s)

# VSCode and Jupyter lab display (and defaults to) this MIME type
Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vegalite.v4+json")}) = true
function Base.show(io::IO, ::MIME"application/vnd.vegalite.v4+json", s::Union{TopLevelSpec, Spec})
    print(io, json(s))
end
function Base.showable(::MIME"application/vnd.vegalite.v4+json", s::Union{TopLevelSpec, Spec})
    properties = propertynames(s)
    :data in properties && :mark in properties && :encoding in properties
end

# Pluto displays this MIME type
function Base.show(io::IO, ::MIME"text/html",  s::Union{TopLevelSpec, Spec})
    print(io, html(s))
end

html_div(spec, div="vis-"*string(hash(rand()), base=16)) = """
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
    div="vis-"*string(hash(rand()), base=16),
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
    div=string(hash(rand()), base=16),
    vega_version=5,
    vegalite_version=5,
    vegaembed_version=6,
) = fullhtml ? html_full(spec; div, vega_version, vegalite_version, vegaembed_version) : html_div(spec, div)
