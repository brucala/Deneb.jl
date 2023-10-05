# ---
# cover: assets/london_tubes.png
# author: bruno
# description: London Tube Lines
# generate_cover: true
# ---

using Deneb

boroughs = Data(
    url="https://vega.github.io/vega-datasets/data/londonBoroughs.json",
    format=(type=:topojson, feature=:boroughs),
)
tubelines = Data(
    url="https://vega.github.io/vega-datasets/data/londonTubeLines.json",
    format=(type=:topojson, feature=:line),
)
centroids = Data(
    url="https://vega.github.io/vega-datasets/data/londonCentroids.json",
    format=(; type=:json),
)

background = boroughs * Mark(
    :geoshape, stroke=:white, strokeWidth=2, color="#eee",
) * vlspec(width=700, height=500)

labels = centroids * Mark(
    :text, size=8, opacity=0.6,
) * Encoding(
    longitude=:cx,
    latitude=:cy,
    text="bLabel:N",
) * transform_calculate(
    bLabel="indexof (datum.name,' ') > 0  ? substring(datum.name,0,indexof(datum.name, ' ')) : datum.name"
)

line_scale = (
    domain=[
        "Bakerloo", "Central", "Circle", "District", "DLR", "Hammersmith & City",
        "Jubilee", "Metropolitan", "Northern", "Piccadilly", "Victoria", "Waterloo & City"
    ],
    range=[
        "rgb(137,78,36)", "rgb(220,36,30)", "rgb(255,206,0)", "rgb(1,114,41)", "rgb(0,175,173)", "rgb(215,153,175)",
        "rgb(106,114,120)", "rgb(114,17,84)", "rgb(0,0,0)", "rgb(0,24,168)", "rgb(0,160,226)", "rgb(106,187,170)"
    ]
)

lines = tubelines * Mark(
    :geoshape, filled=false, strokeWidth=2,
) * Encoding(
    color=field(
        "id:N",
        legend=(title=nothing, orient="bottom-right", offset=0),
        scale=line_scale
    )
)

chart = background + labels + lines

# save cover #src
save("assets/london_tubes.png", chart) #src
