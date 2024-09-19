using Test
using LinearODESolver
using DifferentialEquations

A = [0.5 -0.2; 0.1 0.3]
u0 = [1.0, 0.0]
tspan = (0.0, 50.0)

# test define_system 
@testset "Test LinearODESolver Module" begin
    prob = LinearODESolver.define_system(A, u0, tspan)
    @test prob isa ODEProblem  # 测试返回的是否是 ODEProblem 类型

    # test solve_system 
    sol = LinearODESolver.solve_system(prob)
    @test sol isa ODESolution  # 测试返回的是否是 ODESolution 类型

    # test solution
    @test length(sol.t) > 0  # 确保解的时间步数大于 0

    # test plot
    LinearODESolver.plot_solution(sol)
end