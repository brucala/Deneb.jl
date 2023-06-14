# ---
# cover: assets/input_binding.png
# author: bruno
# description: Interactive Input Binding
# title: Interactive Input Binding (dropdown, range, checkbox, radio widgets)
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

base = data * Mark(:point) * Encoding("Horsepower:Q", "Miles_per_Gallon:Q");

# ## Dropdown Input Widget

chart = base * select_dropdown(
    :origin,
    value=:USA,
    select=(type=:point, fields=[:Origin]),
    options=[nothing, :Europe, :Japan, :USA],
    labels=[:All, :Europe, :Japan, :USA],
) * Encoding(
    color=condition(:origin, field("Cylinders:O"), :grey),
)

# save cover #src
save("assets/input_binding.png", chart) #src

# ## Radio Input Widget

chart = base * select_radio(
    :origin,
    select=(type=:point, fields=[:Origin]),
    options=[nothing, :Europe, :Japan, :USA],
    labels=[:All, :Europe, :Japan, :USA],
    name=:Region,
) * Transform(
    filter=(;param=:origin)
) * Encoding(
    x=(; scale=(; domain=[0, 240])),
    y=(; scale=(; domain=[0, 50])),
)

# ## Range Input Widget

chart = base * select_range(
    :opacity,
    value=50,
    min=1,
    max=100,
) * Mark(
    opacity= (;expr="opacity/100"),
)

# ## Checkbox Input Widget

chart = base * select_checkbox(
    :toggle_origin;
) * Encoding(
    color=condition(:toggle_origin, field("Origin:N"), :grey),
)
