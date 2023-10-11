### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 651cbb70-3852-11ee-0eaf-87d6bfbb89fe
using Deneb

# ╔═╡ e84d6779-3732-4725-b60b-37b9867a0516
penguins = Data(url="https://vega.github.io/vega-datasets/data/penguins.json")

# ╔═╡ 3287d99e-6cbf-4afb-9527-a566eba8b384
base_chart = penguins * Mark(:bar) * Encoding(:Species, "count()")

# ╔═╡ f8376d90-d210-4178-aee9-5f4e6bf8c6c7
md"Let's make wider bars"

# ╔═╡ ec91f8ad-8d83-46b8-bff0-873cc9305fab
bar_chart = base_chart * vlspec(width=200)

# ╔═╡ bbe4aeaa-2fd3-4281-98b8-3fed032305b5
md"Colored by island"

# ╔═╡ 3f2dc6df-1b76-40fb-9bdb-e1324b8b32c9
color_bar_chart = bar_chart * Encoding(color=:Island)

# ╔═╡ a4b5d1bb-e064-44c3-9f3f-9e5d3781a90d
md"And grouped by Island"

# ╔═╡ 411538ec-00ce-4df0-ae56-04162f09d935
group_bar_chart = color_bar_chart * Encoding(xOffset=:Island)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Deneb = "b5a61f88-a05b-4725-9526-4eca17cec623"

[compat]
Deneb = "~0.3.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "12fe441ecb3374941c810b61099fbb7ae74561e4"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefaultApplication]]
deps = ["InteractiveUtils"]
git-tree-sha1 = "c0dfa5a35710a193d83f03124356eef3386688fc"
uuid = "3f0dd361-4fe0-5fc6-8523-80b14ec94d85"
version = "1.1.0"

[[deps.Deneb]]
deps = ["DefaultApplication", "JSON", "MultilineStrings", "NodeJS_18_jll", "REPL", "Tables", "UUIDs"]
git-tree-sha1 = "8ef6aba728cef0dcc3c8634fba5e05c9fac341f9"
uuid = "b5a61f88-a05b-4725-9526-4eca17cec623"
version = "0.3.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MultilineStrings]]
git-tree-sha1 = "3214216b069fb1bc329f55094681e06b64a51022"
uuid = "1e8d2bf6-9821-4900-9a2f-4d87552df2bd"
version = "0.1.1"

[[deps.NodeJS_18_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "82dbe46101dfce63c5a66e7805e6ac453addc4cb"
uuid = "c1e1d063-8311-5f52-a749-c7b05e91ae37"
version = "18.16.1+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"
"""

# ╔═╡ Cell order:
# ╠═651cbb70-3852-11ee-0eaf-87d6bfbb89fe
# ╠═e84d6779-3732-4725-b60b-37b9867a0516
# ╠═3287d99e-6cbf-4afb-9527-a566eba8b384
# ╟─f8376d90-d210-4178-aee9-5f4e6bf8c6c7
# ╠═ec91f8ad-8d83-46b8-bff0-873cc9305fab
# ╟─bbe4aeaa-2fd3-4281-98b8-3fed032305b5
# ╠═3f2dc6df-1b76-40fb-9bdb-e1324b8b32c9
# ╟─a4b5d1bb-e064-44c3-9f3f-9e5d3781a90d
# ╠═411538ec-00ce-4df0-ae56-04162f09d935
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
