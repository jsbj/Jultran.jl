module TestJultran
using Jultran
using FactCheck    

facts("matches values computed from pytran") do
    κ = compute_κs(:co2, [600], 260, 1.e4)[1]
    println(κ)
    @fact abs(κ - 11.2) < 0.01 => true
end

end
