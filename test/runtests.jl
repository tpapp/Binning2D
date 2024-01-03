using Binning2D
using Test
using PolygonOps

using Binning2D: point

####
#### bin interfaces
####

@testset "input conversions" begin
    grid = RectangleGrid()
    xy = point(0.2, 0.3)
    @test bin(grid, xy) ≡ bin(grid, Tuple(xy)) ≡ bin(grid, [xy...])
end

function test_bin_consistency(grid; N = 200, scale = 10.0)
    for _ in 1:N
        xy = point(randn() * scale, randn() * scale)
        b = bin(grid, xy)
        v = vertices(grid, b)
        p = [v..., v[1]]
        @test inpolygon(xy, p) == 1
        (; center, d1, d2) = inner_ellipse(grid, b)
        @test inpolygon(center, p) == 1
        @test inpolygon(center .+ d1, p; on = 1) == 1
        @test inpolygon(center .+ d2, p; on = 1) == 1
    end
end

test_bin_consistency(RectangleGrid())

using JET
@testset "static analysis with JET.jl" begin
    @test isempty(JET.get_reports(report_package(Binning2D, target_modules=(Binning2D,))))
end

@testset "QA with Aqua" begin
    import Aqua
    Aqua.test_all(Binning2D; ambiguities = false)
    # testing separately, cf https://github.com/JuliaTesting/Aqua.jl/issues/77
    Aqua.test_ambiguities(Binning2D)
end