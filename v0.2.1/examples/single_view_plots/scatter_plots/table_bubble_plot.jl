using Deneb
data = Data(url="https://vega.github.io/vega-datasets/data/github.csv")
chart = Data(data) * Mark(:circle) * Encoding(
    x="hours(time):O",
    y=field(
        "day(time):O",
        sort=[:mon, :tue, :wed, :thu, :fri, :sat, :sun]
    ),
    size="sum(count):Q"
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

