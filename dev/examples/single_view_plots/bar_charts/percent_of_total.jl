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

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
