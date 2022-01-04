# ---
# cover: assets/vertical_concat.png
# author: bruno
# description: Vertical Concatenation
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/weather.csv")

base = Transform(filter="datum.location === 'Seattle'") * vlspec(height=200)

bar = Mark(:bar) * Encoding("month(date):O", "mean(precipitation):Q")

bubble = Mark(:point) * Encoding(
    x=field("temp_min:Q", bin=true),
    y=field("temp_max:Q", bin=true),
    size="count()",
)

chart = data * base * [bar; bubble]

save("assets/vertical_concat.png", chart)  #src
