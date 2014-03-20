module Jultran
export compute_κs

# look up table for gass' hitran codes, molecular weights, partition function
gases = {
    :h2o => [1, 18, T -> T^1.5],
    :co2 => [2, 44, T -> T],
    :ch4 => [6, 16, T -> T^1.5]
}

# contants
N = 6.022136736e23
h = 6.626075540e-34
c = 2.99792458e8
k = 1.38065812e-23

# compute absorption coefficients (kg/m^2 per cm^-1) directly from HITRAN lines
function compute_κs(gas, νs::Range, T, p)
    num_widths = 1e3 # number of multiples of line width (γ) before truncation
    
    gas_array = gases[gas]
    file_name = "$(Pkg.dir())/Jultran/data/$(@sprintf "%02d" gas_array[1])_hit04.par"
    ν_grid_min, ν_grid_step, ν_grid_max = νs[1], step(νs), νs[end]
    length_νs = length(νs)
    κs = zeros(Float64, length_νs)
    
    Q = gas_array[3] # partition function
    T_fact = (.1N/gas_array[2]) * (Q(296.)/Q(T))
    for line in eachline(open(file_name))
        # check if line is nonempty and is first isotopologue
        if (length(line) > 0) && (line[3] == '1')
            ν = float(line[4:15]) # wavenumber
            # air-broadened line width, with temperature dependence:
            γ = float(line[36:40]) * (p/1.013e5) * (296/T)^float(line[56:59])

            ν_min, ν_max  = ν + [-1,1] * num_widths * γ
            if (ν_min <= ν_grid_max) && (ν_max >= ν_grid_min)
                i_min = max(1, 1 + iceil((ν_min-ν_grid_min)/ν_grid_step))
                i_max = min(length_νs, 1 + ifloor((ν_max-ν_grid_min)/ν_grid_step))
                
                # intensity (S), converted to (m^2/kg per cm^-1),
                # and multiplied by two factors expressing T-dependence,
                # and the partition function:
                f = -100h * c/k
                S = float(line[16:25]) * T_fact * exp(f*float(line[46:55])*(1/T-1/296)) * expm1(f*ν/T) / expm1(f*ν/296)
            
                κs[i_min:i_max] += S * γ / (π * ((ν-νs[i_min:i_max]).^2 + γ^2))
            end
        end
    end
    
    κs
end


# iw = 1+int(length_νs*(ν-ν_grid_min)/(ν_grid_max-ν_grid_min))
# nsum = int(num_widths*γ/ν_grid_step)
# i_min = max(1,iw-nsum)
# i_max = min(length_νs,iw+nsum)
# 
# if (i_max > 1) && (i_min < length_νs)
#     νs = ((i_min-iw):(i_max-iw))*ν_grid_step
#     println(i_min)
#     f = -100h * c/k
#     S = float(line[16:25]) * T_fact * exp(f*float(line[46:55])*(1/T-1/296)) * expm1(f*ν/T) / expm1(f*ν/296) 
#     κs[i_min:i_max] += S * γ / (π * (νs.^2 + γ^2))                
# end

end # module
