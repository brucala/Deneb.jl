using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/disasters.csv")
chart = Data(data) * transform_filter(
    "datum.Entity !== 'All natural disasters'"
) * Mark(
    :circle,
    opacity=0.8,
    stroke="black",
    strokeWidth=1,
    strokeOpacity=0.4
) * Encoding(
    x=field("Year:T", title="", axis=(; grid=false)),
    y=field("Entity:N", title="", axis=(; offset=20)),
    color=field("Entity:N", legend=nothing),
    tooltip=[
        field("Entity:N"),
        field("Year:T", format="%Y"),
        field("Deaths:Q", format="~s")
    ],
    size=field(
        "Deaths:Q",
        title="Annual Global Deaths",
        legend=(clipHeight=30, format='s'),
        scale=(; rangeMax=5000),
    )
) * title(
    text="Global Deaths from Natural Disasters (1900-2017)",
    subtitle="The size of the bubble represents the total death count per year, by type of disaster",
    anchor=:start,
) * config(
    :view, stroke=""
) * vlspec(
    width=600,
    height=400,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
