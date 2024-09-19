# week 2 lec

#=
macro make_square(var)
    return quote
        @eval function square($var)
            return $var * $var
        end
    end
end

@make_square x 

println(square(5))
=#



#=
macro define_sum_function(rows, cols)
    quote
        @eval function $(Symbol("sum_$(rows)x$(cols)"))(matrix::Matrix{Float64})
            if size(matrix) != ($(rows), $(cols))
                throw(ArgumentError($("Matrix must be $(rows)x$(cols)")))
            end
            return sum(matrix)
        end
    end
end

@define_sum_function 2 2
@define_sum_function 3 3

#Test for 2x2 matrix
matrix_2x2 = [1.0 2.0; 3.0 4.0]
result_2x2 = sum_2x2(matrix_2x2)
println("Sum of 2x2 matrix: ", result_2x2) # Expected: 10.0

# Test for 3x3 
matrix_3x3 = [1.0 2.0 3.0; 4.0 5.0 6.0; 7.0 8.0 9.0]
result_3x3 = sum_3x3(matrix_3x3)
println("Sum of 3x3 matrix: ", result_3x3)

# Test invalid cases
try
    sum_2x2(matrix_3x3)
catch e 
    println("Caught expected error: ", e)
end
=#




#=
using Pkg
Pkg.add("Zygote")
using Zygote

function f(x)
    return x^3 + 2*x^2 + x 
end

x= 2.0
gradient = Zygote.gradient(f, x)[1]
println("Gradient of f at x = $x: $gradient")
=#


#=
#week 2 exercise 1 
using Pkg
Pkg.add("ForwardDiff")
using ForwardDiff

# Macro Definition
macro gradient_expr(expr)
    return quote
        @eval function gradient_func(values::Vector)
            f = $(expr) 
            grad = ForwardDiff.gradient(x -> f(x...), values)
            return grad 
        end 
    end
end
# Example usage
@gradient_expr (x, y) -> x^2 + y^2

#Create the gradient function
gradient_func = gradient_func

# compute the gradient at the point (1, 2).
result = gradient_func([1.0, 2.0])
println("Gradient at (1, 2): ", result)  # output: [2.0, 4.0]

=#

# exerciese 2 
using Pkg 
Pkg.add("Zygote")
using Zygote
#Define the macro 
macro diff_macro(expr)
    #Create value_func and deriv_func
    return quote
        #Define value_func to compute the value of the expression
        @eval function value_func(x)
            return $(expr)
        end

        #Define deriv_func to compute the derivative using Zygote
        @eval function deriv_func(x)
            return Zygote.gradient(x->$(expr), x)[1]           
        end
    end
    
end
#example usage 
@diff_macro x^2 + 3*x + 5 
# Test the generated functions
println("Value at x = 2 : ", value_func(2))
println("Derivative at x = 2: ", deriv_func(2))