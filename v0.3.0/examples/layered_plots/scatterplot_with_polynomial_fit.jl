using Deneb

x = rand(50) .^ 2
y = 10 .- 1.0 ./ (x .+ 0.1) .+ randn(50)
data = (; x, y)

points = Data(data) * Mark(:circle, color=:black) * Encoding("x:Q", "y:Q")

lines = points * Mark(:line) * Encoding(color="degree:N") * layer(
    transform_regression(
        :x, :y;
        method=:poly,
        order=order,
        as=(:x, string(order))
    ) * transform_fold(
        [string(order)], as=(:degree, :y)
    )
    for order in (1, 3, 5)
)

chart = (points + lines) * vlspec(width=400)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

