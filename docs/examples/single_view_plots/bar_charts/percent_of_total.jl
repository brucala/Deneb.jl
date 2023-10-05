# ---
# cover: assets/percent_of_total.png
# author: bruno
# description: Sorted Bar Chart
# generate_cover: true
# ---

using Deneb

data = (
    Activity=["Sleeping", "Eating", "TV", "Work", "Exercise"],
    Time=[8, 2, 4, 8, 2],
)

chart = Data(data) * Mark(:bar) * transform_joinaggregate(
    TotalTime="sum(Time)"
) *transform_calculate(
    PercentOfTotal="datum.Time/datum.TotalTime * 100"
) * Encoding(
    x=field("PercentOfTotal:Q", title="% of total Time"),
    y="Activity:N"
)

save("assets/percent_of_total.png", chart)  #src
