using PGFPlotsX, DocumentPGFPlots, Test

x = LinRange(0,1,10)
P = Plot(Table(x,sin.(x)))
cd(@__DIR__())
try;rm("test.pdf");catch end
try;rm("test.svg");catch end
try;rm("test.tex");catch end
try;rm("test.tikz");catch end

DocumentPGFPlots.savefigs("test",P)
@test Base.isfile("test.pdf")
@test Base.isfile("test.svg")
@test Base.isfile("test.tex")
@test Base.isfile("test.tikz")
try;rm("test.pdf");catch end
try;rm("test.svg");catch end
try;rm("test.tex");catch end
try;rm("test.tikz");catch end
push!(ARGS,"docker")
DocumentPGFPlots.savefigs("test",P)
@test Base.isfile("test.pdf")
@test Base.isfile("test.svg")
@test Base.isfile("test.tex")
@test Base.isfile("test.tikz")
try;rm("test.pdf");catch end
try;rm("test.svg");catch end
try;rm("test.tex");catch end
try;rm("test.tikz");catch end
pop!(ARGS)
push!(ARGS,"native")
DocumentPGFPlots.savefigs("test",P)
@test Base.isfile("test.pdf")
@test Base.isfile("test.svg")
@test Base.isfile("test.tex")
@test Base.isfile("test.tikz")
pop!(ARGS)
