import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

print('Starting Italy Energy Analysis (Python)...\n')

# Download
url = 'https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv'
print('Loading data from OWID...')
df = pd.read_csv(url)

# Filter Italy
italy = df[df['country'] == 'Italy'].sort_values('year')

print(f'Data loaded: {italy.shape}\n')

# Use oil consumption (most reliable data)
col = 'oil_consumption'
italy_clean = italy[['year', col]].dropna()

print(f'Using column: {col}')
print(f'Years: {int(italy_clean["year"].min())} to {int(italy_clean["year"].max())}')
print(f'Data points: {len(italy_clean)}\n')

years = italy_clean['year'].values
values = italy_clean[col].values

print('=== HISTORICAL STATISTICS ===')
print(f'Mean: {values.mean():.2f} TWh')
print(f'Std Dev: {values.std():.2f} TWh')
print(f'Min: {values.min():.2f} TWh')
print(f'Max: {values.max():.2f} TWh\n')

# Linear regression for trend
x = np.arange(len(years))
coeffs = np.polyfit(x, values, 1)
slope, intercept = coeffs[0], coeffs[1]

print('=== LINEAR REGRESSION MODEL ===')
print(f'Slope: {slope:.6f} TWh/year')
print(f'Intercept: {intercept:.2f} TWh')
print(f'Trend: {"DECREASING" if slope < 0 else "INCREASING"}\n')

# Generate 10-year forecast
forecast_x = np.arange(len(years), len(years) + 10)
forecast = np.polyval(coeffs, forecast_x)
future_years = np.arange(int(max(years) + 1), int(max(years) + 11))

print('=== 10-YEAR FORECAST FOR ITALY (OIL CONSUMPTION) ===')
print('Year | Forecast (TWh)')
for y, v in zip(future_years, forecast):
    print(f'{int(y)}  | {v:.2f}')

# Plot
plt.figure(figsize=(12, 6))
plt.plot(years, values, 'o-', linewidth=2.5, markersize=6, label='Historical Data', color='#1f77b4')
plt.plot(future_years, forecast, 's--', linewidth=2.5, markersize=6, label='10-Year Forecast', color='#d62728')
plt.axvline(max(years) + 0.5, color='gray', linestyle=':', alpha=0.4, linewidth=2)

plt.xlabel('Year', fontsize=12, fontweight='bold')
plt.ylabel('Oil Consumption (TWh)', fontsize=12, fontweight='bold')
plt.title('Italy Oil Consumption: Historical & 10-Year Forecast (2026-2035)', fontsize=14, fontweight='bold')
plt.legend(fontsize=11, loc='best')
plt.grid(True, alpha=0.3, linestyle='--')
plt.tight_layout()

plt.savefig('italy_energy_forecast_python.png', dpi=150, bbox_inches='tight')
print('\n✓ Plot saved: italy_energy_forecast_python.png')

print('\nAnalysis complete!')
