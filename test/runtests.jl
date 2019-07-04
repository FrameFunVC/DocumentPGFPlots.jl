using PGFPlotsX, DocumentPGFPlots, Test

x = LinRange(0,1,10)
P = Plot(Table(x,sin.(x)))
cd(@__DIR__())
try;rm("test.pdf");catch end
try;rm("test.svg");catch end
try;rm("test.tex");catch end
try;rm("test.tikz");catch end

@testset "natural" begin
    run(`ls`)
    DocumentPGFPlots.savefigs("test",P)
    run(`ls`)
    @test Base.isfile("test.pdf")
    @test Base.isfile("test.svg")
    @test Base.isfile("test.tex")
    @test Base.isfile("test.tikz")
    try;rm("test.pdf");catch end
    try;rm("test.svg");catch end
    try;rm("test.tex");catch end
    try;rm("test.tikz");catch end
end

if !(Base.Sys.which("docker")===nothing)
    @testset "docker" begin
        push!(ARGS,"docker")
        run(`ls`)
        DocumentPGFPlots.savefigs("test",P)
        run(`ls`)
        @test Base.isfile("test.pdf")
        @test Base.isfile("test.svg")
        @test Base.isfile("test.tex")
        @test Base.isfile("test.tikz")
        try;rm("test.pdf");catch end
        try;rm("test.svg");catch end
        try;rm("test.tex");catch end
        try;rm("test.tikz");catch end
        pop!(ARGS)
    end
end
if !(Base.Sys.which("latexmk")===nothing&&Base.Sys.which("pdf2svg")===nothing)
    @testset "native" begin
        push!(ARGS,"native")
        run(`ls`)
        DocumentPGFPlots.savefigs("test",P)
        run(`ls`)
        @test Base.isfile("test.pdf")
        @test Base.isfile("test.svg")
        @test Base.isfile("test.tex")
        @test Base.isfile("test.tikz")
        pop!(ARGS)
    end
end
