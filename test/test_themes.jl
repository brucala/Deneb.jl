using Deneb: specvalue, themespec

@testset "Test set_theme!" begin
    @test specvalue(themespec()) == (;config=Deneb.DEFAULT_CONFIG)
    set_theme!(:empty)
    @test specvalue(themespec()) == (;)
    set_theme!(:empty, :dark)
    @test specvalue(themespec()) == (;
        usermeta=(;embedOptions=(;theme="dark"))
    )
    set_theme!(:dark)
    @test specvalue(themespec()) == (
        config=Deneb.DEFAULT_CONFIG,
        usermeta=(;embedOptions=(;theme="dark"))
    )
end

s = "{\n  \"config\": {\n    \"view\": {\n      \"continuousWidth\": 300,\n      \"continuousHeight\": 300,\n      \"step\": 25\n    },\n    \"mark\": {\n      \"tooltip\": true\n    }\n  },\n  \"usermeta\": {\n    \"embedOptions\": {\n      \"theme\": \"dark\"\n    }\n  }\n}\n"
@testset "Test print_theme" begin
    @test sprint(print_theme) == s
end

@testset "Test json" begin
    @test Deneb.json(spec(), 2) == "{}\n"
    @test Deneb.json(vlspec(),2) == s
end

set_theme!(:default)
