# ---
# cover: assets/comet_chart.png
# author: bruno
# description: Comet Chart
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/barley.json")

chart = data * config(
    :legend, orient=:bottom, direction=:horizontal
) * title(
    "Barley Yield comparison between 1932 and 1931"
) * transform_pivot(
    :year, :yield; groupby=[:variety, :site]
) * transform_fold(
    ["1931", "1932"], as=["year", "yield"]
) * transform_calculate(
    delta="datum['1932'] - datum['1931']",
) * Mark(:trail) * Encoding(
    x=field("year:O", title=nothing),
    y=field("variety:N", title=:Variety),
    size=field(
        "yield:Q",
        scale=(;range=[0, 12]),
        legend=(;values=[20, 60]),
        title="Barley Yield (bushels/acre)",
    ),
    color=field(
        "delta:Q",
        scale=(;domainMid=0),
        title="Yield Delta (%)"
    ),
    column=field("site:N", title=:Site),
)

save("assets/comet_chart.png", chart)  #src
