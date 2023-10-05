# ---
# cover: assets/scatterplot_with_loess_lines.png
# author: bruno
# description: Scatter Plot with LOESS lines
# generate_cover: true
# ---

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

save("assets/scatterplot_with_loess_lines.png", chart)  #src
