@testset "test interactive_scales" begin
    s = interactive_scales()
    @test s isa Deneb.ParamsSpec
    @test rawspec(s) == [(name="interactive_scales", select="interval", bind="scales")]
    s = interactive_scales(bindy=false)
    @test rawspec(s) == [(name="interactive_scales_x", select=(type="interval", encodings=["x"]), bind="scales")]
    s = interactive_scales(bindx=false)
    @test rawspec(s) == [(name="interactive_scales_y", select=(type="interval", encodings=["y"]), bind="scales")]
    s = interactive_scales(shift_on_y=true)
    @test rawspec(s) == [
        (name="interactive_scales_x", select=(type="interval", encodings=["x"], zoom="wheel![!event.shiftKey]", translate= "[mousedown[!event.shiftKey], mouseup] > mousemove"), bind="scales"),
        (name="interactive_scales_y", select=(type="interval", encodings=["y"], zoom="wheel![event.shiftKey]", translate= "[mousedown[event.shiftKey], mouseup] > mousemove"), bind="scales")
    ]
end

@testset "test select_point/interval" begin
    s = select_point(:sp)
    @test s isa Deneb.ParamsSpec
    @test rawspec(s) == [(name="sp", select=(; type="point"))]
    s = select_point(:org, on=:mouseover, nearest=true, fields=[:origin], empty=false, value=1)
    @test rawspec(s) == [(name="org", value=1, select=(type="point", on="mouseover", nearest=true, fields=["origin"], empty=false))]
    s = select_interval(:org, on=:mouseover, nearest=true, fields=[:origin], empty=false, value=1)
    @test rawspec(s) == [(name="org", value=1, select=(type="interval", on="mouseover", nearest=true, fields=["origin"], empty=false))]
end

@testset "test select_legend" begin
    s = select_legend(:leg)
    @test s isa Deneb.ParamsSpec
    @test rawspec(s) == [(name="leg", select=(type="point", encodings=["color"]), bind="legend")]
    s = select_legend(:leg; field=:x, bind_options=:dblclick)
    @test rawspec(s) == [(name="leg", select=(type="point", fields=["x"]), bind=(;legend="dblclick"))]
end

@testset "test select_bind" begin
    s = select_range(:pname, value=6, min=0, max=12, step=0.1)
    @test s isa Deneb.ParamsSpec
    @test rawspec(s) == [(name="pname", value=6, bind=(input="range", min=0, max=12, step=0.1))]
    s = select_dropdown(:origin, value=:USA, select=(type=:point, fields=[:Origin]), options=[nothing, :Europe], labels=[:All, :Europe])
    @test rawspec(s) == [(name="origin", value="USA", select=(type="point", fields=["Origin"]), bind=(input="select", options=[nothing, "Europe"], labels=["All", "Europe"]))]
    s = select_radio(:origin, value=:USA, select=(type=:point, fields=[:Origin]), options=[nothing, :Europe], labels=[:All, :Europe], name=:Region)
    @test rawspec(s) == [(name="origin", value="USA", select=(type="point", fields=["Origin"]), bind=(input="radio", options=[nothing, "Europe"], labels=["All", "Europe"], name="Region"))]
    s = select_checkbox(:toggle)
    @test rawspec(s) == [(name="toggle", bind=(; input="checkbox"))]
    s = select_bind_input(:color, :europe; value="blue")
    @test rawspec(s) == [(name="europe", value="blue", bind=(; input="color"))]
end

@testset "test condition" begin
    @test condition(:p, 1, 2) == (condition=(param=:p, value=1), value=2)
    @test condition(:p, field("x:o"), 2) == (condition=(param=:p, field="x", type="ordinal"), value=2)
    @test condition(:p, 1, 2; empty=true) == (condition=(param=:p, empty=true, value=1), value=2)
    @test condition([:p1=>1, :p2=>2], 3) == (condition=[(param=:p1, value=1), (param=:p2, value=2)], value=3)
    @test condition([:p1=>1, :p2=>2], 3, empty=[true, false]) == (condition=[(param=:p1, empty=true, value=1), (param=:p2, empty=false, value=2)], value=3)

    @test condition_test("condition", 1, 2) == (condition=(test="condition", value=1), value=2)
    @test condition_test("condition", field("x:o"), 2) == (condition=(test="condition", field="x", type="ordinal"), value=2)
    @test condition_test(["c1"=>1, "c2"=>2], 3) == (condition=[(test="c1", value=1), (test="c2", value=2)], value=3)
end
