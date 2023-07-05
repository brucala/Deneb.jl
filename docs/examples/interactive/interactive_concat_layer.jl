# ---
# cover: assets/interactive_concat_layer.png
# author: bruno
# title: Interactive Dashboard with Cross Highlight
# ---

using Deneb

data = Data(url="https://vega.github.io/vega-datasets/data/movies.json")

top_base = Encoding(
    x=field("IMDB Rating", bin=(;maxbins=10)),
    y=field("Rotten Tomatoes Rating", bin=(;maxbins=10)),
)

top_rect = Mark(:rect) * Encoding(
    color=field(
        "count()",
        legend=(
            title="All Movies Count",
            direction=:horizontal,
            gradientLength=120,
        )
    )
)

top_point = Mark(:point) * transform_filter(
    param(:pts)
) * Encoding(
    size=field("count()", legend=(;title="Selected Category Count")),
    color=(; value="#666"),
)

top = top_base * (top_rect + top_point)

bottom = Mark(:bar) * select_point(
    :pts, encodings=[:x],
) * Encoding(
    x=field("Major Genre", axis=(; labelAngle=-40)),
    y="count()",
    color=condition(:pts, :steelblue, :grey)
) * vlspec(width=420, height=120)

chart = data * [top; bottom] * resolve_legend(
    color=:independent, size=:independent
)

# save cover #src
save("assets/interactive_concat_layer.png", chart) #src
