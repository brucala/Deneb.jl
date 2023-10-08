# ---
# cover: assets/waterfall_chart.png
# author: bruno
# description: Waterfall Chart of Monthly Profit and Loss
# ---

using Deneb

data = (
    label=["Begin", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "End"],
    amount=[4000, 1707, -1425, -1030, 1812, -1067, -1481, 1228, 1176, 1146, 1205, -1388, 1492, 0],
)

base = Data(data) * transform_window(
    sum="sum(amount)",
    lead="lead(label)",
) * transform_calculate(
    lead="datum.lead === null ? datum.label : datum.lead",
    prev_sum="datum.label === 'End' ? 0 : datum.sum - datum.amount",
    amount="datum.label === 'End' ? datum.sum : datum.amount",
    text_amount="(datum.label !== 'Begin' && datum.label !== 'End' && datum.amount > 0 ? '+' : '') + datum.amount",
    center="(datum.sum + datum.prev_sum) / 2",
    sum_dec="datum.sum < datum.prev_sum ? datum.sum : ''",
    sum_inc="datum.sum > datum.prev_sum ? datum.sum : ''",
) * Encoding(
    x=field(
        "label:O",
        axis=(title=:Months, labelAngle=0),
        sort=nothing,
    )
)

bar = Mark(:bar, size=45) * Encoding(
    y=field("prev_sum:Q", title=:Amount),
    y2="sum:Q",
    color=condition_test(
        [
            "datum.label === 'Begin' || datum.label === 'End'" => "#f7e0b6",
            "datum.sum < datum.prev_sum" => "#f78a64",
        ],
        "#93c4aa",
    ),
)

rule = Mark(
    :rule, xOffset=-22.5, x2Offset=22.5,
) * Encoding(
    y="sum:Q",
    x2="lead",
)

top_text = Mark(
    :text, baseline=:bottom, dy=-4,
) * Encoding(
    text="sum_inc:N",
    y="sum_inc:Q"
)

bottom_text = Mark(
    :text, baseline=:top, dy=4
) * Encoding(
    text="sum_dec:N",
    y="sum_dec:Q"
)

mid_text = Mark(
    :text, baseline=:middle, color=:white,
) * Encoding(
    text="text_amount:N",
    y="center:Q",
)

chart = base * (
    bar + rule  + top_text + bottom_text + mid_text
) * vlspec(width=800, height=450) * config(
    :text, fontWeight=:bold, color="#404040"
)

save("assets/waterfall_chart.png", chart)  #src
