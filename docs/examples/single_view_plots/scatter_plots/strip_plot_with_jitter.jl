# ---
# cover: assets/strip_plot_with_jitter.png
# author: bruno
# description: Strip Plot with Jitter
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

base = Data(data) * Mark(:circle, size=8) * Encoding(
    x="IMDB Rating:Q",
    y="Major Genre:N",
    yOffset="jitter:Q",
    color=field("Major Genre:N", legend=nothing),
)

## Generate Gaussian jitter with a Box-Muller transform
gaussian_jitter = Transform(
    calculate="sqrt(-2*log(random()))*cos(2*PI*random())",
    as=:jitter,
) * vlspec(
    title="Normally distributed jitter",
)

## Generate uniform jitter
uniform_jitter = Transform(
    calculate="random()",
    as=:jitter,
) * vlspec(
    title="Uniformly distributed jitter"
) * Encoding(y=(; axis=nothing));

chart = base * [gaussian_jitter uniform_jitter] * spec(
    resolve=(; scale=(; yOffset="independent")),
)


# save cover #src
save("assets/strip_plot_with_jitter.png", chart) #src
