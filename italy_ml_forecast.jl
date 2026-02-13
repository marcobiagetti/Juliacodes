using CSV, DataFrames, Downloads, Statistics, Plots

println("Starting Italy Energy Consumption Analysis...")

# Download energy dataset
url = "https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv"
filename = "owid-energy-data.csv"

if !isfile(filename)
    println("Downloading energy data...")
    Downloads.download(url, filename)
else
    println("Energy data file already exists")
end

# Load data
println("Loading energy data...")
energy_data = CSV.read(filename, DataFrame)

# Filter for Italy
italy_data = filter(row -> row.country == "Italy", energy_data)
sort!(italy_data, :year)

println("Italy Energy Data Shape: $(size(italy_data))")

# Get columns with energy info
energy_cols = [col for col in names(italy_data) if contains(string(col), "consumption") || contains(string(col), "energy")]
println("Available energy columns: $energy_cols")

# Use primary energy consumption
target_col = :primary_energy_consumption
if target_col in names(italy_data)
    italy_clean = dropmissing(italy_data[:, [:year, target_col]])
    
    println("\nData after cleaning: $(size(italy_clean))")
    println("Year range: $(minimum(italy_clean.year)) - $(maximum(italy_clean.year))")
    
    # Get data
    years = italy_clean.year
    values = italy_clean[!, target_col]
    
    println("\nBasic Statistics:")
    println("Mean: $(round(mean(values), digits=2))")
    println("Std: $(round(std(values), digits=2))")
    println("Min: $(round(minimum(values), digits=2))")
    println("Max: $(round(maximum(values), digits=2))")
    
    # Calculate linear trend for forecast
    n = length(years)
    x = collect(0:(n-1))
    
    # Simple linear regression: y = a + b*x
    coeff_matrix = [ones(n) x]
    coeffs = coeff_matrix \ values
    a, b = coeffs[1], coeffs[2]
    
    println("\n=== LINEAR REGRESSION MODEL ===")
    println("Intercept: $(round(a, digits=2))")
    println("Slope: $(round(b, digits=4))")
    
    # Generate 10-year forecast
    future_x = n:(n+9)
    forecast = a .+ b .* future_x
    future_years = (maximum(years) + 1):(maximum(years) + 10)
    
    println("\n=== 10-YEAR FORECAST FOR ITALY ===")
    println("Year | Forecast")
    for (year, val) in zip(future_years, forecast)
        println("$year | $(round(val, digits=2))")
    end
    
    # Create visualization
    plot(years, values, label="Historical Data", linewidth=2, marker=:circle, markersize=4)
    plot!(future_years, forecast, label="10-Year Forecast", linewidth=2, marker=:square, markersize=4, linestyle=:dash, color=:red)
    vline!([maximum(years) + 0.5], label="", linestyle=:dot, color=:gray, alpha=0.5)
    
    plot!(xlabel="Year", ylabel="Primary Energy Consumption (TWh)", 
          title="Italy Energy Consumption Forecast", legend=:topright, size=(900, 500))
    
    savefig("italy_forecast.png")
    println("\nVisualization saved as: italy_forecast.png")
    
else
    println("Primary energy consumption data not available for Italy")
    println("Available columns in Italy data:")
    println(names(italy_data))
end

println("\nAnalysis complete!")
