using Deneb

data = (
    x=1:100,
    A=cumsum(randn(100)),
    B=cumsum(randn(100)),
    C=cumsum(randn(100)),
)

base = Data(data) * transform_fold(
    [:A, :B, :C],
    as=(:category, :y),
) * Encoding("x:Q", "y:Q", color=:category)

points = Mark(:circle, opacity=0.4)

lines = Mark(:line, size=4) * transform_loess(
    :x, :y, groupby=:category
)

chart = base * (points + lines) * vlspec(width=400)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

