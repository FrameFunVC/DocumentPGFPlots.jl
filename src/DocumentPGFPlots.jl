module DocumentPGFPlots

using PGFPlotsX

function savefigs(filename, obj; all=true, render=true)
    if render
        pgfsave(filename * ".tex", obj);
        pgfsave(filename * ".tikz", obj;include_preamble=false);
    end
    if all
        if "docker" in ARGS
            compile_tex(filename * ".tex", "docker")
            pdf2svg(filename, "docker")
        elseif "native" in ARGS
            compile_tex(filename * ".tex", "native")
            pdf2svg(filename, "native")
        else
            compile_tex(filename * ".tex")
            pdf2svg(filename)
        end
    end
    return nothing
end

function piperun(cmd)
    verbose = "verbose" in ARGS || get(ENV, "DOCUMENTER_VERBOSE", "false") == "true"
    run(pipeline(cmd, stdout = verbose ? stdout : "LaTeXWriter.stdout",
                      stderr = verbose ? stderr : "LaTeXWriter.stderr"))
end

function compile_tex(texfile::String, platform = (Sys.which("latexmk") === nothing) ? "docker" : "native")
    thisdir = pwd()
    if platform == "native"
        Sys.which("latexmk") === nothing && (@error "LaTeXWriter: latexmk command not found."; return false)
        @info "LaTeXWriter: using latexmk to compile tex."
        try
            p = splitdir(texfile)[1]=="" ? pwd() : splitdir(texfile)[1]
            cd(p)
            piperun(`latexmk -f -interaction=nonstopmode -view=none -lualatex -shell-escape $(Base.basename(texfile))`)
            return true
        catch err
            logs = cp(pwd(), mktempdir(); force=true)
            @error "LaTeXWriter: failed to compile tex with latexmk. "
            return false
        end
    else
        Sys.which("docker") === nothing && (@error "LaTeXWriter: docker command not found."; return false)
        @info "LaTeXWriter: using docker to compile tex."
        script = """
            mkdir /home/zeptodoctor/build
            cd /home/zeptodoctor/build
            cp -r /mnt/. .
            latexmk -f -interaction=nonstopmode -view=none -lualatex -shell-escape $(Base.basename(texfile))
        """
        try
            p = splitdir(texfile)[1]=="" ? pwd() : splitdir(texfile)[1]
            piperun(`docker run -itd -u zeptodoctor --name latex-container -v $(p):/mnt/ --rm juliadocs/documenter-latex:0.1`)
            piperun(`docker exec -u zeptodoctor latex-container bash -c $(script)`)
            piperun(`docker cp latex-container:/home/zeptodoctor/build/. $(p)`)
            return true
        catch err
            logs = cp(pwd(), mktempdir(); force=true)
            @error "LaTeXWriter: failed to compile tex with docker. Look for LaTeXWriter.stderr, LaTeXWriter.stdout"
            return false
        finally
            cd(thisdir)
            try; piperun(`docker stop latex-container`); catch; end
        end
    end
end

function pdf2svg(figname::String, platform = (Sys.which("pdf2svg") === nothing ) ? "docker" : "native")
    if platform=="native"
        Sys.which("pdf2svg") === nothing && (@error "pdf2svg."; return false)
        @info "using pdf2svg to transform pdf to svg."
        try
            run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`)
            return true
        catch err
            logs = cp(pwd(), mktempdir(); force=true)
            @error "failed to create svg with pdf2svg. "
            return false
        end
    else
        Sys.which("docker") === nothing && (@error "docker command not found."; return false)
        @info "using docker to create svg."
        try
            p = splitdir(figname)[1]=="" ? pwd() : splitdir(figname)[1]
            piperun(`docker run -itd  -v $(p):/mnt/  --rm vincentcoppe/pdf2svg pdf2svg /mnt/$(Base.basename(figname)).pdf /mnt/$(Base.basename(figname)).svg`)
            return true
        catch err
            @error "failed to create svg with docker."
            return false
        finally
        end
    end
end

end # module
