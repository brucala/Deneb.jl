using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/seattle-weather.csv")

properties = vlspec(width=600) * title("Seattle Weather: 2012-2015")

scale=(
    domain=[:sun, :fog, :drizzle, :rain, :snow],
    range=["#e7ba52", "#a7a7a7", "#aec7e8", "#1f77b4", "#9467bd"]
)
color = field("weather:N"; scale)

points = Mark(:point) * transform_filter(
    param(:click)
) * select_interval(
    :brush, encodings=[:x],
) * Encoding(
    x=field("monthdate(date):T", title=:Date, axis=(;format="%b")),
    y=field(
        "temp_max:Q",
        title="Maximum Daily Temperature (C)",
        scale=(;domain=[-5, 40]),
    ),
    color=condition(:brush, color, :lightgray),
    size=field("precipitation:Q", scale=(; domain=[-1, 50]))
)

bars = Mark(:bar) * transform_filter(
    param(:brush)
) * select_point(
    :click, encodings=[:color]
) * Encoding(
    x="count():Q",
    y="weather:N",
    color=condition(:click, color, :lightgray),
) * vlspec(height=100)

chart = data * properties * [points; bars]

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

