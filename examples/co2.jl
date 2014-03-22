using Jultran
using PyPlot

νs = 25:.001:3000
κs = compute_κs(:ch4, νs, 260, 1.e4)
semilogy(νs,κs)
