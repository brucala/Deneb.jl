# ---
# cover: assets/facet_rows_and_columns.png
# author: bruno
# description: Facet View (rows and columns)
# ---

using Deneb

data = (
    a=repeat(["a1", "a2", "a3"], inner=9),
    b=repeat(["b1", "b2", "b3"], inner=3, outer=3),
    c=repeat(["x", "y", "z"], outer=9),
    p=rand(27),
)

chart = Data(data) * Mark(:bar) * Facet(
    row=field(:a, title="Factor A", header=(;labelAngle=0)),
    column=field(:b, title="Factor B"),
) * Encoding(
    x=field("p:q", axis=(;format="%"), title=nothing),
    y=field(:c, axis=nothing),
    color=field(
        :c,
        legend=(orient=:bottom, titleOrient=:left),
        title=:settings
    ),
) * vlspec(
    height=(;step=10), width=100
)

# save cover #src
save("assets/facet_rows_and_columns.png", chart) #src

# ## `column` and `row` as an encoding channels:

chart = Data(data) * Mark(:bar) * Encoding(
    x=field("p:q", axis=(;format="%"), title=nothing),
    y=field(:c, axis=nothing),
    color=field(
        :c,
        legend=(orient=:bottom, titleOrient=:left),
        title=:settings
    ),
    row=field(:a, title="Factor A", header=(;labelAngle=0)),
    column=field(:b, title="Factor B"),
) * vlspec(
    height=(;step=10), width=100
)
