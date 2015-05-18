output_path(file, dir) = begin
    if isdir(dir)
        out = abspath(joinpath(dir, file))
        # TODO: mkdir(joinpath(dir, basename(file)))
        return replace(out, r".jl$", ".html")
    elseif endswith(dir, ".html")
        return dir
    else
        throw("Target $dir doesn't exist")
    end
end

escher_make(file, output; single_file=false, assets_dir="output/assets") = begin
    opath = output_path(file, output)
end
