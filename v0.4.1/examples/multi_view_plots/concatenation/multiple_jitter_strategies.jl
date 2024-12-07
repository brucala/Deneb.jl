using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

base = Data(data) * Mark(:circle, size=8) * Encoding(
    x="IMDB Rating:Q",
    y="Major Genre:N",
    yOffset="jitter:Q",
    color=field("Major Genre:N", legend=nothing),
)

# Generate Gaussian jitter with a Box-Muller transform
gaussian_jitter = transform_calculate(
    jitter="sqrt(-2*log(random()))*cos(2*PI*random())",
) * title("Normally distributed jitter")

# Generate uniform jitter
uniform_jitter = transform_calculate(
    jitter="random()",
) * title(
    "Uniformly distributed jitter"
) * Encoding(y=(; axis=nothing));

chart = base * [gaussian_jitter uniform_jitter] * resolve_scale(
    yOffset=:independent
)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
