# ---
# cover: assets/ridgeline_plot.png
# author: bruno
# description: Facet Area (rows)
# ---

using Deneb

data = Data(url="https://cdn.jsdelivr.net/npm/vega-datasets@v1.29.0/data/seattle-weather.csv")

config_options = vlspec(
    height=20
) * config(
    :axis, grid=false
) * config(
    :view, stroke=nothing
) * title(text="Seattle Weather", anchor=:end)

chart = Data(data) * config_options * transform_timeunit(
    Month="month(date)"
) * transform_joinaggregate(
    mean_temp="mean(temp_max)", groupby=:Month,
) * transform_bin(
    :temp_max, (:bin_max, :bin_min),
) * transform_aggregate(
    value="count()", groupby=[:Month, :mean_temp, :bin_min, :bin_max],
) * transform_impute(
    :value, :bin_min;
    groupby=[:Month, :mean_temp], value=0,
) * Mark(
    :area,
    interpolate=:monotone,
    fillOpacity=0.8,
    stroke=:lightgray,
    strokeWidth=0.5,
    title="Seattle Weather",
) * Facet(
    row=field(
        "Month:T",
        title=nothing,
        header=(labelAngle=0, labelAlign=:right, format="%B")
    ),
) * Encoding(
    x=field("bin_min:Q", bin=:binned, title="Maximum Daily Temperature (C)"),
    y=field("value:Q", scale=(;range=[20, -20]), axis=nothing),
    fill=field(
        "mean_temp:Q",
        legend=nothing,
        scale=(domain=[30,5], scheme=:redyellowblue),
    ),
) * layout(bounds=:flush, spacing=0)

# save cover #src
save("assets/ridgeline_plot.png", chart) #src
