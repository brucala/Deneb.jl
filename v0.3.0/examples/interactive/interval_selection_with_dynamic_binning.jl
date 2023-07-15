using Deneb

data = Data(
    url="https://vega.github.io/vega-datasets/data/flights-5k.json",
    format=(; parse=(; date=:date)),
)

base = data * Mark(:bar) * transform_calculate(
    time="hours(datum.date) + minutes(datum.date) / 60",
) * Encoding(
    x=field("time", bin=(; maxbins=30)),
    y="count()"
) * vlspec(width = 600)

upper = Encoding(
    x=(
        title="",
        bin=(; extent=param(:brush)),
    )
)

lower = select_interval(
    :brush,
    encodings=[:x],
) * vlspec(height=60)

chart = base * [upper; lower]

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

