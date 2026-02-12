using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Downloads")
Pkg.add("Statistics")
Pkg.add("Plots")    
using Downloads 
using CSV 
using DataFrames
# download a global energy dataset and load it into a DataFrame
url = "https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv"
filename = "owid-energy-data.csv"
Downloads.download(url, filename)
energy_data = CSV.read(filename, DataFrame)
pwd() # check current working directory
first(energy_data, 5) # preview the first 5 rows of the dataset