using CSV, DataFrames, Downloads, Statistics, Plots

println("Starting Italy Energy Consumption Analysis...\n")

# Download energy dataset
url = "https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv"
filename = "owid-energy-data.csv"

if !isfile(filename)
    println("Downloading energy data...")
    Downloads.download(url, filename)
else
    println("Using cached energy data")
end

# Load data
println("Loading energy data...")
energy_data = CSV.read(filename, DataFrame)

# Filter for Italy
italy_data = filter(row -> row.country == "Italy", energy_data)
sort!(italy_data, :year)

println("Data loaded: $(size(italy_data)) rows × columns")

# Try different energy consumption columns
columns_to_try = [:fossil_fuel_consumption, :oil_consumption, :gas_consumption, :coal_consumption]

target_col = nothing
italy_clean = nothing

for col in columns_to_try
    if col in names(italy_data)
        temp = dropmissing(italy_data[:, [:year, col]])
        if !isempty(temp) && length(temp.year) > 5
            target_col = col
            italy_clean = temp
            println("Using column: $col with $(nrow(italy_clean)) non-missing values\n")
            break
        end
    end
end

if !isnothing(italy_clean) && !isnothing(target_col)
    years = italy_clean.year
    values = italy_clean[!, target_col]
    
    println("=== DATA SUMMARY ===")
    println("Years covered: $(minimum(years)) to $(maximum(years))")
    println("Data points: $(length(values))")
    println("Mean: $(round(mean(values), digits=2))")
    println("Std: $(round(std(values), digits=2))")
    println("Min: $(round(minimum(values), digits=2))")
    println("Max: $(round(maximum(values), digits=2))\n")
    
    # Linear regression for trend
    n = length(years)
    x = collect(0:(n-1))
    coeff_matrix = [ones(n) x]
    coeffs = coeff_matrix \ values
    a, b = coeffs[1], coeffs[2]
    
    println("=== LINEAR REGRESSION MODEL ===")
    println("Intercept: $(round(a, digits=4))")
    println("Slope: $(round(b, digits=6))")
    println("Trend: $(b > 0 ? "INCREASING" : "DECREASING")\n")
    
    # Generate 10-year forecast
    future_x = collect(n:(n+9))
    forecast = a .+ b .* future_x
    future_years = collect((maximum(years) + 1):(maximum(years) + 10))
    
    println("=== 10-YEAR FORECAST FOR ITALY ===")
    for (i, year) in enumerate(future_years)
        println("$year | $(round(forecast[i], digits=2))")
    end
    
    # Plot
    plot(years, values, label="Historical Data", linewidth=2.5, marker=:circle, markersize=5, color=:blue)
    plot!(future_years, forecast, label="10-Year Forecast", linewidth=2.5, marker=:square, 
          markersize=5, linestyle=:dash, color=:red)
    vline!([maximum(years) + 0.5], label="", linestyle=:dot, color=:gray, alpha=0.3)
    
    plot!(xlabel="Year", ylabel="Energy Consumption (TWh)", 
          title="Italy Energy Consumption: Historical & 10-Year Forecast",
          legend=:topright, size=(1000, 600), dpi=100)
    
    savefig("italy_energy_forecast.png")
    println("\n✓ Visualization saved: italy_energy_forecast.png")
    
else
    println("ERROR: Could not find suitable energy data for Italy")
end

println("Analysis complete!")
