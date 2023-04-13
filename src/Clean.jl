module Clean

using Comonicon: @main

using JuliaFormatter: format_file, format_text

using BioLab

function _clean_nb(nb; ke_ar...)

    ke_va = BioLab.Dict.read(nb)

    kem_vam = ke_va["metadata"]

    ju = kem_vam["language_info"]["name"] == "julia"

    if ju

        kem_vam["language_info"]["version"] = string(VERSION)

        kem_vam["kernelspec"]["name"] = "julia-$(VERSION.major).$(VERSION.minor)"

    end

    kec_vac_ = Vector{Dict{String, Any}}()

    for kec_vac in ke_va["cells"]

        if kec_vac["cell_type"] == "code"

            so = string(strip(join(kec_vac["source"])))

            if isempty(so)

                continue

            end

            kec_vac["execution_count"] = nothing

            kec_vac["outputs"] = Vector{String}()

            if ju

                li_ = split(format_text(so; ke_ar...), '\n')

                kec_vac["source"] = vcat(["$li\n" for li in li_[1:(end - 1)]], li_[end])

            end

            kec_vac["metadata"] = Dict{String, Any}()

        end

        push!(kec_vac_, kec_vac)

    end

    ke_va["cells"] = kec_vac_

    BioLab.Dict.write(nb, ke_va; id = 1)

    return nothing

end

"""
🧼 Command-line program for cleaning `Julia` files (`.jl`) and `Jupyter Notebook`s (`.ipynb`).
📍 Learn more at https://github.com/KwatMDPhD/Clean.jl.

# Arguments

  - `paths`: `.jl` or `.ipynb` paths.
"""
@main function clean(paths...)

    ke_ar = BioLab.Dict.symbolize(BioLab.Dict.read(joinpath(@__DIR__, "JuliaFormatter.toml")))

    for pa in paths

        println("🧼 $pa")

        ex = splitext(pa)[2]

        if ex == ".jl"

            format_file(pa; ke_ar...)

        elseif ex == ".ipynb"

            _clean_nb(pa; ke_ar...)

        else

            error()

        end

    end

    return nothing

end

end
