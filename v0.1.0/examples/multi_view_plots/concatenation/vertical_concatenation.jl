using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/weather.csv")

base = transform_filter("datum.location === 'Seattle'") * vlspec(height=200)

bar = Mark(:bar) * Encoding("month(date):O", "mean(precipitation):Q")

bubble = Mark(:point) * Encoding(
    x=field("temp_min:Q", bin=true),
    y=field("temp_max:Q", bin=true),
    size="count()",
)

chart = data * base * [bar; bubble]

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

