# ---
# cover: assets/encoding_channels_binding.png
# author: bruno
# description: Encoding Channels Binding
# ---

# There is no direct way to map an encoding channel to a widget in order to
# dynamically bind axes to different fields (https://github.com/vega/vega-lite/issues/7365).
# In the meantime, the example below illustrates a workaround that achieves the same
# functionality.

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

chart = data * Mark(:circle) * select_dropdown(
    :x;
    value=:Horsepower,
    options=[:Horsepower, :Displacement, :Weight_in_lbs, :Acceleration, :Miles_per_Gallon],
    name="X-axis",
) * select_dropdown(
    :y;
    value=:Miles_per_Gallon,
    options=[:Horsepower, :Displacement, :Weight_in_lbs, :Acceleration, :Miles_per_Gallon],
    name="Y-axis"
) * Transform(
    calculate="datum[x]", as=:x
) * Transform(
    calculate="datum[y]", as=:y
) * Encoding(
    x=field("x:Q", axis=(; title=expr(:x))),
    y=field("y:Q", axis=(; title=expr(:y))),
    color="Origin:N",
)


# save cover #src
save("assets/encoding_channels_binding.png", chart) #src
