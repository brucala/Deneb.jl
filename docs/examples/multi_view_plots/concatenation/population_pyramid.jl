# ---
# cover: assets/population_pyramid.png
# author: bruno
# description: Population Pyramid
# generate_cover: true
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/population.json")

base = Data(data) * transform_filter(
    "datum.year == 2000"
) * transform_calculate(
    gender="datum.sex == 2 ? 'Female' : 'Male'",
) * config(
    :view, stroke=nothing
) * config(
    :axis, grid=false
)

left = Mark(:bar) * transform_filter(
    field(:gender, equal=:Female)
) * Encoding(
    x=field(
        "sum(people)",
        title=:population,
        axis=(;format=:s),
        sort=:descending,
    ),
    y=field(:age, axis=nothing, sort=:descending),
    color=field(
        :gender,
        scale=(;range=["#675193", "#ca8861"]),
        legend=nothing,
    ),
) * title(:Female)

right = Mark(:bar) * transform_filter(
    field(:gender, equal=:Male),
) * Encoding(
    x=field(
        "sum(people)",
        title=:population,
        axis=(;format=:s),
    ),
    y=field(:age, axis=nothing, sort=:descending),
    color=field(:gender, legend=nothing),
) * title(:Male)

middle = Mark(:text, align=:center) * Encoding(
    y=field("age:O", axis=nothing, sort=:descending),
    text="age:Q"
)

chart = base * [left middle right] * layout(spacing=0)

save("assets/population_pyramid.png", chart)  #src
