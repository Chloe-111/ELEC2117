import Pkg
Pkg.add("Optim")
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

# Function to run the simulation
function run_simulation(c, β, γ, γ_s, α, p_s, S0, I0, Is0, R0, tspan)
    u0 = [S0, I0, Is0, R0]
    p = (c, β, γ, γ_s, α, p_s)
    prob = ODEProblem(sir_model!, u0, tspan, p) 
    sol = solve(prob, Tsit5(), saveat=1.0)
    return sol
end

# Parameters
c = 8                            # Contact rate per day
β_guess = 0.033                   # Initial guess for transmission probability
γ = 1/7                          # Recovery rate for infected (7 days)
γ_s = 1/14                       # Recovery rate for severe illness (14 days)
α = 1/30                         # Rate of immunity loss (1 month)
p_s = 0.2                        # Proportion of severe cases

# Initial conditions
N = 6000
S0 = N - 1                       # Initial susceptible population
I0 = 1                           # Initial infected individual
Is0 = 0                          # Initial severe cases
R0 = 0                           # Initial recovered population
tspan = (0.0, 31.0)              # Time span for simulation (31 days for alignment with data)

# Run the simulation with initial guess for β
sol = run_simulation(c, β_guess, γ, γ_s, α, p_s, S0, I0, Is0, R0, tspan)

# Observed data for infected people and severe illness (from Department of Health)
observed_days = 16:31
observed_infected = [11, 7, 20, 3, 29, 14, 11, 12, 16, 10, 58, 34, 26, 29, 51, 55]
observed_severe_days = 22:31
observed_severe = [0, 0, 1, 2, 5, 5, 5, 2, 9, 4]


# Plot the model predictions and observed data for comparison
plot(sol.t, sol[2, :], label="Model Prediction", xlabel="Days", ylabel="Number Infected", lw=2, legend=:topright)
scatter!(observed_days, observed_infected, label="Observed Infected", color=:red, marker=:circle, ms=4)
scatter!(observed_severe_days, observed_severe, label="Observed Severe Cases", color=:blue, marker=:square, ms=4)
title!("Comparison of Model Prediction and Observed Data")

# Calculation of R0 using estimated parameters
function calculate_R0(c, β, γ)
    return c * β / γ
end

R0_estimate = calculate_R0(c, β_guess, γ)
println("Estimated R0 with β_guess: ", R0_estimate)


# range of β
β_1 = 0.03  
β_2 = 0.038   

sol_β1 = run_simulation(c, β_1, γ, γ_s, α, p_s, S0, I0, Is0, R0, tspan)
sol_β2 = run_simulation(c, β_2, γ, γ_s, α, p_s, S0, I0, Is0, R0, tspan)

# plot
plot(sol_β1.t, sol_β1[2, :], label="Model Prediction (β = $β_1)", color=:blue, lw=2)
plot!(sol_β2.t, sol_β2[2, :], label="Model Prediction (β = $β_2)", color=:blue, lw=2, linestyle=:dash)
scatter!(observed_days, observed_infected, label="Observed Infected", color=:red, marker=:circle, ms=4)
scatter!(observed_severe_days, observed_severe, label="Observed Severe Cases", color=:blue, marker=:square, ms=4)
xlabel!("Days")
ylabel!("Number Infected")
title!("Comparison of Model Prediction and Observed Data")


