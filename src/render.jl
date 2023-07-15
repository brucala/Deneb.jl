JSON.json(s::AbstractSpec) = json(rawspec(s))
JSON.json(s::AbstractSpec, indent) = json(rawspec(s), indent)
JSON.json(s::VegaLiteSpec) = json(rawspec(themespec() * s))
JSON.json(s::VegaLiteSpec, indent) = json(rawspec(themespec() * s), indent)

Base.show(io::IO, s::AbstractSpec) = print(io, json(s, 2))

Base.show(io::IO, ::MIME"text/plain", s::AbstractSpec) = print(io, "$(typeof(s)): \n", s)

Base.show(io::IO, ::MIME"application/json", s::AbstractSpec) = show(io, s)

# VSCode displays (and defaults to) this MIME type
Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vegalite.v5+json")}) = true
function Base.show(io::IO, ::MIME"application/vnd.vegalite.v5+json", s::VegaLiteSpec)
    print(io, json(s))
end

# Pluto and Jupyter display this MIME type
function Base.show(io::IO, ::MIME"text/html",  s::VegaLiteSpec)
    print(io, html(s; html_func=html_universal))
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

###
### Convert to image
###

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

###
### HTML templates
###

html_div(spec::VegaLiteSpec; div="vis-"*string(uuid4()), kw...) = """
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

function html_full(
    spec::VegaLiteSpec;
    div="vis-"*string(uuid4()),
    vega_version=5,
    vegalite_version=5,
    vegaembed_version=6,
    kw...,
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
    $(indent(html_div(spec; div), 4))
    </body>
    </html>
    """
end

# Template taken from Vega-Altair v5
function html_universal(
    spec::VegaLiteSpec;
    div="vis-"*string(uuid4()),
    vega_version=5,
    vegalite_version=5,
    vegaembed_version=6,
    kw...,
)
    """
    <style>
      #$div.vega-embed {
        width: 100%;
        display: flex;
      }

      #$div.vega-embed details,
      #$div.vega-embed details summary {
        position: relative;
      }
    </style>
    <div id="$div"></div>
    <script type="text/javascript">
      var VEGA_DEBUG = (typeof VEGA_DEBUG == "undefined") ? {} : VEGA_DEBUG;
      (function(spec, embedOpt){
        let outputDiv = document.currentScript.previousElementSibling;
        if (outputDiv.id !== "$div") {
          outputDiv = document.getElementById("$div");
        }
        const paths = {
          "vega": "https://cdn.jsdelivr.net/npm/vega@$vega_version?noext",
          "vega-lib": "https://cdn.jsdelivr.net/npm/vega-lib?noext",
          "vega-lite": "https://cdn.jsdelivr.net/npm/vega-lite@$vegalite_version?noext",
          "vega-embed": "https://cdn.jsdelivr.net/npm/vega-embed@$vegaembed_version?noext",
        };

        function maybeLoadScript(lib, version) {
          var key = `\${lib.replace("-", "")}_version`;
          return (VEGA_DEBUG[key] == version) ?
            Promise.resolve(paths[lib]) :
            new Promise(function(resolve, reject) {
              var s = document.createElement('script');
              document.getElementsByTagName("head")[0].appendChild(s);
              s.async = true;
              s.onload = () => {
                VEGA_DEBUG[key] = version;
                return resolve(paths[lib]);
              };
              s.onerror = () => reject(`Error loading script: \${paths[lib]}`);
              s.src = paths[lib];
            });
        }

        function showError(err) {
          outputDiv.innerHTML = `<div class="error" style="color:red;">\${err}</div>`;
          throw err;
        }

        function displayChart(vegaEmbed) {
          vegaEmbed(outputDiv, spec, embedOpt)
            .catch(err => showError(`Javascript Error: \${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
        }

        if(typeof define === "function" && define.amd) {
          requirejs.config({paths});
          require(["vega-embed"], displayChart, err => showError(`Error loading script: \${err.message}`));
        } else {
          maybeLoadScript("vega", "$vega_version")
            .then(() => maybeLoadScript("vega-lite", "$vegalite_version"))
            .then(() => maybeLoadScript("vega-embed", "$vegaembed_version"))
            .catch(showError)
            .then(() => displayChart(vegaEmbed));
        }
      })($(json(spec)), {"mode": "vega-lite"});
    </script>
    """
end

html(spec;
    html_func=html_full,
    div="vis-"*string(uuid4()),
    vega_version=5,
    vegalite_version=5,
    vegaembed_version=6,
) = html_func(spec; div, vega_version, vegalite_version, vegaembed_version)

###
### Save
###

function save(filename::AbstractString, mime::AbstractString, s::VegaLiteSpec)
    showable(s, mime) || return
    open(filename, "w") do f
        show(f, mime, s)
    end
end

function save(filename::AbstractString, s::VegaLiteSpec)
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
        return write(filename, html(s))
    else
        throw(ArgumentError("Unknown file type."))
    end
    save(filename, mime, s)
end

###
### Display in a browser
###

function Base.display(spec::VegaLiteSpec)
    # write html in temporary file
    path = tempname() * ".html"
    write(path, html(spec))
    # launch browser tab with the html chart
    DefaultApplication.open(path)
end
