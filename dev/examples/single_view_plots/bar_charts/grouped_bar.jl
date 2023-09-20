using Deneb
data = (
    category=collect("AAABBBCCC"),
    group=collect("xyzxyzxyz"),
    value=rand(9)
)
chart = Data(data) * Mark(:bar) * Encoding(
    :category,
    "value:q",
    xOffset=:group,
    color=:group,
)

Data(data) * Mark(:bar, tooltip=true) * Encoding(
    :group,
    "value:q",
    color=:group,
    column=:category,
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
