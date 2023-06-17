# ---
# cover: assets/isotype_with_emoji.svg
# author: bruno
# description: Isotype Visualization with Emoji
# ---

using Deneb

data = (
    country=vcat(repeat(["Great Britain"], 15), repeat(["United States"], 20)),
    animal=vcat(
        repeat(["cattle"], 3), repeat(["pigs"], 2), repeat(["sheep"], 10),
        repeat(["cattle"], 9), repeat(["pigs"], 5), repeat(["sheep"], 6)
    )
)

chart = Data(data) * Mark(
    :text, size=65, baseline=:middle,
) * transform_calculate(
    emoji="{'cattle': '🐄', 'pigs': '🐖', 'sheep': '🐏'}[datum.animal]",
) * transform_window(
    rank="rank()",
    groupby=[:country, :animal],
) * Encoding(
    x=field("rank:O", axis=nothing),
    y=field("animal:O", axis=nothing),
    row=field("country:N", title=""),
    text="emoji:N",
) * vlspec(
    width=800,
    height=200,
    config=(;view=(; stroke=""))
)

save("assets/isotype_with_emoji.svg", chart)  #src
