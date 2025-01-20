using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

base = data * Mark(:point) * Encoding("Horsepower:Q", "Miles_per_Gallon:Q");

chart = base * select_dropdown(
    :origin,
    value=:USA,
    select=(type=:point, fields=[:Origin]),
    options=[nothing, :Europe, :Japan, :USA],
    labels=[:All, :Europe, :Japan, :USA],
) * Encoding(
    color=condition(:origin, field("Cylinders:O"), :grey),
)

chart = base * select_radio(
    :origin,
    select=(type=:point, fields=[:Origin]),
    options=[nothing, :Europe, :Japan, :USA],
    labels=[:All, :Europe, :Japan, :USA],
    name=:Region,
) * transform_filter(
    param(:origin)
) * Encoding(
    x=(; scale=(; domain=[0, 240])),
    y=(; scale=(; domain=[0, 50])),
)

chart = base * select_range(
    :opacity,
    value=50,
    min=1,
    max=100,
) * Mark(
    opacity=expr("opacity/100"),
)

chart = base * select_checkbox(
    :toggle_origin;
) * Encoding(
    color=condition(:toggle_origin, field("Origin:N"), :grey),
)

chart = base * select_bind_input(
    :color, :usa;
    value="#317bb4"
) * select_bind_input(
    :color, :europe;
    value="#ffb54d"
) * select_bind_input(
    :color, :japan;
    value="#adadad"
) * Encoding(
    color=field(
        "Origin:N",
        scale=(
            domain=["USA", "Europe", "Japan"],
            range=[expr(:usa), expr(:europe), expr(:japan)],
        ),
    )
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
