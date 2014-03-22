using Gaia, Tyndall, Jultran

Ts = 200:10:300
νs = 25:.1:40000

sunlight_νs, sunlight_Ws = sunlight()
println("sunlight done")
json = {
    :sunlight => {
        :values => sunlight_Ws,
        :νs => sunlight_νs
    },
    :νs => [νs[1],νs[end]],
    :ts => Ts,
    :data => Array(Dict, length(Ts))
}


earthlight_νs = 25:.1:10000
for (i,T) in enumerate(Ts)
    json[:data][i] = {
        :earthlight => {
            :values => [planck(ν, T) for ν in earthlight_νs],
            :νs => earthlight_νs
        }
    }
    
    for gas=[:co2,:ch4,:h2o] #,:n2o]
        κs = compute_κs(gas, νs, T, 1.e4)
        
        json[:data][i][gas] = {
            :values => nonzeros(κs),
            :νs => νs[findn(κs)[1]]
        }
    end
end

JSON.print(open("data/spectrum.json", "w"), json)