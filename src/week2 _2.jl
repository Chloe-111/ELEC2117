# In-place updates (!Function)

#=
#Non-in-place Update:
function increment_non_inplace(x)
    return x .+ 1
end

a = [1, 2, 3]
b = increment_non_inplace(a)
println(b) #[2,3,4]
println(a) #[1,2,3]

#In-place Update:

function increment_inplace!(x)
    x .= x .+ 1 #.+= means element-wise addition and in-place modification
end

a = [1, 2, 3]
increment_inplace!(a)
println(a) #[2,3,4]

=#




#=
#Differential Equations in julia 
using Pkg
Pkg.add("DifferentialEquations")
Pkg.add("Plots")

using Plots
using DifferentialEquations

function f!(du, u, p, t)
    du[1] = -2u[1] + 1 
end

u0 = [0.0] #Initial Condition
tspan = (0.0, 5.0) #Time span
prob = ODEProblem(f!, u0, tspan)

sol = solve(prob)

plot(sol, xlabel="Time", ylabel="y", title="Solution of ODE")
=#




#=
using Plots
using DifferentialEquations

function f!(du, u, p,t)
    α, β = p
    du[1] = -α*u[1] + β
end

u0 = [0.0] #Initial Condition
tspan = (0.0, 5.0) 
p = (4.0, 3.0)

prob = ODEProblem(f!, u0, tspan, p)

sol = solve(prob)

plot(sol, xlabel="Time", ylabel="y", title"Solution of ODE with parameters")

=#



#=
#exercise 1
using Plots 
using DifferentialEquations

A = [0.5 -0.2 ; 0.1 0.3]

function linear_ode!(du, u, p, t)
    du[1] = A[1,1]*u[1] + A[1,2]*u[2]
    du[2] = A[2,1]*u[1] + A[2,2]*u[2]
end

u0 = [1.0, 0.0] #Initial Condition
tspan = (0.0, 50.0)
prob = ODEProblem(linear_ode!, u0, tspan)

sol = solve(prob)
plot(sol, xlabel="Time", ylabel="y", label=["x1" "x2"], title="Solution of x1 x2 over time")

=#

module LinearODESolver

using DifferentialEquations
using Plots

# Define 
# 1
function define_system(A::Matrix, u0::Vector, tspan::Tuple)
    function linear_ode!(du, u, p, t)
        du[1] = A[1,1]*u[1] + A[1,2]*u[2]  # dx1/dt
        du[2] = A[2,1]*u[1] + A[2,2]*u[2]  # dx2/dt
    end
    prob = ODEProblem(linear_ode!, u0, tspan)
    return prob
end

# 2
function solve_system(prob::ODEProblem)
    return solve(prob)
end

# 3
function plot_solution(sol::ODESolution)
    plot(sol, xlabel="Time", ylabel="x", label=["x1" "x2"], title="Solution of x1 and x2 over time")
end

end  # Module end



