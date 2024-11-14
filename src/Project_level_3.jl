using Pkg
Pkg.add(["Optim", "DifferentialEquations", "Plots"])

using Optim
using DifferentialEquations
using Plots

# Define the SIRS model with severe illness
function sir_model!(du, u, p, t)
    S, I, Is, R = u              # Unpack compartments
    c, β, γ, γ_s, α, p_s = p     # Unpack parameters
    N = S + I + Is + R           # Total population

    # Differential equations
    du[1] = -c * β * S * I / N + α * R                          # dS/dt 
    du[2] = c * β * S * I / N - γ * I                           # dI/dt
    du[3] = γ * p_s * I - γ_s * Is                              # dIs/dt
    du[4] = γ * (1 - p_s) * I + γ_s * Is - α * R                # dR/dt
end

# Simulation function
function run_simulation(params, S0, I0, Is0, R0, tspan)
    u0 = [S0, I0, Is0, R0]
    prob = ODEProblem(sir_model!, u0, tspan, params)
    sol = solve(prob, Tsit5(), saveat=1.0)
    return sol
end

# Error calculation function based on infected and severe case data
function calculate_total_error(params, observed_infected, observed_severe, observed_days, observed_severe_days)
    c, β, γ, γ_s, α, p_s = params
    S0, I0, Is0, R0 = 6000 - 1, 1, 0, 0  # Initial conditions
    tspan = (0.0, 35.0)  # Time span
    sol = run_simulation(params, S0, I0, Is0, R0, tspan)
    
    # Calculate error for infected cases
    simulated_infected = [sol[2, Int(day)] for day in observed_days]
    error_I = sum((simulated_infected .- observed_infected).^2)
    
    # Calculate error for severe cases
    simulated_severe = [sol[3, Int(day)] for day in observed_severe_days]
    error_Is = sum((simulated_severe .- observed_severe).^2)
    
    # Total error
    return error_I + error_Is
end

# Observed data
observed_days = 16:31
observed_infected = [11, 7, 20, 3, 29, 14, 11, 12, 16, 10, 58, 34, 26, 29, 51, 55]
observed_severe_days = 22:31
observed_severe = [0, 0, 1, 2, 5, 5, 5, 2, 9, 4]

# Fixed parameters; only vary β over a range
c, γ, γ_s, α, p_s = 8.0, 1/7, 1/14, 1/30, 0.2
β_range = range(0.03, 0.038, length=20)
errors = Float64[]

# Calculate total error for each value of β
for β in β_range
    params = [c, β, γ, γ_s, α, p_s]
    error = calculate_total_error(params, observed_infected, observed_severe, observed_days, observed_severe_days)
    push!(errors, error)
end

# Find the β value that minimizes the error
min_error, min_index = findmin(errors)
optimal_β = β_range[min_index]
println("Optimal β: ", optimal_β)
println("Minimum Error: ", min_error)

# Plot the error as a function of β
plot(β_range, errors, xlabel="β", ylabel="Total Error", label="Error as function of β", lw=2)
title!("Error as a Function of β")

# Run simulation with the optimal β value and plot results
optimal_params = [c, optimal_β, γ, γ_s, α, p_s]
sol = run_simulation(optimal_params, 6000 - 1, 1, 0, 0, (0.0, 35.0))

# Plot comparison of model prediction and observed data
plot(sol.t, sol[2, :], label="Model Prediction - Infected", xlabel="Days", ylabel="Number of Cases", lw=2)
scatter!(observed_days, observed_infected, label="Observed Infected", color=:red, marker=:circle, ms=4)
plot!(sol.t, sol[3, :], label="Model Prediction - Severe Cases", lw=2)
scatter!(observed_severe_days, observed_severe, label="Observed Severe Cases", color=:blue, marker=:square, ms=4)
title!("Comparison of Model Prediction and Observed Data")
