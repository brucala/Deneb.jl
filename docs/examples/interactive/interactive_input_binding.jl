# ---
# cover: assets/input_binding.png
# author: bruno
# description: Interactive Input Binding
# title: Interactive Input Binding
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/cars.json")

base = data * Mark(:point) * Encoding("Horsepower:Q", "Miles_per_Gallon:Q");

# ## Dropdown Input Widget

chart = base * Params(
    name=:org,
    select=(type=:point, fields=[:Origin]),
    value=:USA,
    bind=(input=:select, options=[nothing, :Europe, :Japan, :USA]),
) * Encoding(
    color=condition(:org, field("Cylinders:O"), :grey),
)

# save cover #src
save("assets/input_binding.png", chart) #src

# ## Range Input Widget

base *= Transform(calculate="year(datum.Year)", as=:Year)

bottom_points = Mark(:circle, color=:grey, opacity=0.5) * Params(
    name=:CylYr,
    select=(type=:point, fields=[:Cylinders, :Year]),
    value=(Cylinders=4, Year=1977),
    bind=(
        Cylinders=(input=:range, min=3, max=8, step=1),
        Year=(input=:range, min=1969, max=1981, step=1),
    ),
)

top_points = Mark(:circle, size=150) *  Transform(
    filter=(;param=:CylYr)
) * Encoding(color=:Origin)

chart = base * (bottom_points + top_points)
