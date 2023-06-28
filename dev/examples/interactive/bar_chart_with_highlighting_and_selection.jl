using Deneb

data = (a=string.('A':'L'), b=rand(0:100, 12))

chart = Data(data) * Mark(
    :bar,
    stroke=:black,
    cursor=:pointer,
    width=(;band=0.9),
) * select_point(
    :highlight, on=:mouseover
) * select_point(
    :select
) * Encoding(
    "a:n",
    "b:q",
    fillOpacity=condition(:select, 1, 0.3),
    strokeWidth=(
        condition=[
            (param=:select, empty=false, value=2),
            (param=:highlight, empty=false, value=1),
        ],
        value=0,
    )
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

