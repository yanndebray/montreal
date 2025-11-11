# Montreal Weather Sine Fitting Application

A comprehensive MATLAB application for analyzing weather data using sine fitting and various regression models. This app allows you to explore temperature patterns for any city worldwide with flexible model selection.

![Montreal Weather App](img/app_screenshot.png)

## Features

### 🎯 Core Functionality
- **Sine Fitting**: Default model for capturing seasonal temperature variations
- **Linear Regression**: Analyze long-term warming or cooling trends
- **Polynomial Regression**: Fit 2nd, 3rd, or 4th degree polynomials for complex patterns

### 🌍 Data Source
- Fetches historical weather data from the [Open-Meteo API](https://open-meteo.com/)
- Access to global weather archive data
- Temperature (max, min, average) and precipitation data

### 📊 Visualizations
1. **Fitted Model Plot**: Shows actual temperature vs. model predictions
2. **Temperature Variations**: Daily max, min, and average temperatures over time
3. **Residual Plot**: Assess model fit quality
4. **Precipitation**: Bar chart of daily precipitation

### 📈 Statistics
- R² (coefficient of determination)
- RMSE (Root Mean Square Error)
- Temperature statistics (mean, min, max, range, standard deviation)
- Model-specific parameters (amplitude, period, phase for sine; slope/intercept for linear)

## Installation & Requirements

### Requirements
- MATLAB R2020b or later
- No additional toolboxes required (uses built-in functions)
- Internet connection for fetching weather data

### Quick Start

1. Navigate to the application directory:
```matlab
cd('c:\Users\ydebray\Downloads\montreal\vscode')
```

2. Run the application:
```matlab
montreal_weather_sine_app
```

## Usage Guide

### 1. Select a City

**Option A: Quick Select**
- Click one of the preset city buttons (Montreal, Paris, New York, London, Tokyo, Sydney)

**Option B: Manual Entry**
- Enter city name (optional, for display purposes)
- Enter latitude and longitude coordinates

### 2. Choose Time Range

**Option A: Quick Date Range**
- Click "1 year", "2 years", or "3 years" for common ranges

**Option B: Custom Range**
- Enter start date in YYYY-MM-DD format (e.g., 2022-01-01)
- Enter end date in YYYY-MM-DD format (e.g., 2023-12-31)

**Recommended ranges by model:**
- **Sine fitting**: 1-3 years (captures seasonal cycles)
- **Linear regression**: 30 days - 5 years
- **Polynomial**: 30 days - 2 years (avoid overfitting with longer ranges)

### 3. Select Model Type

Choose from the dropdown menu:
- **Sine** (default): Best for capturing seasonal temperature variations
- **Linear**: Best for identifying long-term warming/cooling trends
- **Polynomial (2nd)**: Captures curved trends with one inflection point
- **Polynomial (3rd)**: Captures more complex patterns
- **Polynomial (4th)**: For very complex patterns (use with caution - may overfit)

### 4. Analyze

Click the **"🔍 Analyze Weather with Sine Fitting"** button to:
- Fetch data from the API
- Fit the selected model
- Generate visualizations
- Display statistics

## Model Details

### Sine Model
```
T(t) = A·sin(2π·t/P + φ) + C
```
Where:
- **A**: Amplitude (half of temperature range)
- **P**: Period (days for complete cycle)
- **φ**: Phase shift (timing of temperature peaks)
- **C**: Vertical offset (mean temperature)

**Best for**: Capturing annual/seasonal temperature cycles

**Interpretation**: 
- Amplitude shows how much temperature varies seasonally
- Period indicates the length of the seasonal cycle (typically ~365 days)
- Phase indicates when the warmest/coldest periods occur

### Linear Model
```
T(t) = m·t + b
```
Where:
- **m**: Slope (°C per day)
- **b**: Intercept (temperature at t=0)

**Best for**: Detecting long-term warming or cooling trends

**Interpretation**:
- Positive slope indicates warming
- Negative slope indicates cooling
- Slope magnitude shows rate of temperature change

### Polynomial Models
```
2nd degree: T(t) = a·t² + b·t + c
3rd degree: T(t) = a·t³ + b·t² + c·t + d
4th degree: T(t) = a·t⁴ + b·t³ + c·t² + d·t + e
```

**Best for**: Complex patterns with multiple turning points

**Caution**: Higher-degree polynomials can overfit data, especially with noise

## Interpreting Results

### R² (R-squared)
- **> 0.9**: Excellent fit - model captures data very well
- **0.7 - 0.9**: Good fit - model explains most variation
- **0.5 - 0.7**: Moderate fit - captures general trend
- **< 0.5**: Poor fit - consider different model or more data

### RMSE (Root Mean Square Error)
- Average prediction error in °C
- Lower values indicate better fit
- Compare RMSE between models to choose the best one

### Residual Plot
- Points should scatter randomly around zero
- Patterns in residuals suggest model inadequacy
- Funnel shapes indicate heteroscedasticity

## Example Use Cases

### 1. Seasonal Temperature Analysis
**Goal**: Understand annual temperature cycle in Montreal

**Settings**:
- City: Montreal, Canada
- Date range: 2 years
- Model: Sine

**What to look for**:
- Amplitude: How much temperature varies between summer and winter
- Period: Should be close to 365 days
- Phase: When temperatures peak (summer) and trough (winter)

### 2. Climate Change Trend Detection
**Goal**: Detect warming trend over time

**Settings**:
- City: Any location
- Date range: 5-10 years
- Model: Linear

**What to look for**:
- Slope: Positive values indicate warming
- R²: How much of temperature variation is explained by the trend
- Compare with sine model to separate seasonal vs. long-term trends

### 3. Complex Pattern Analysis
**Goal**: Analyze unusual temperature patterns

**Settings**:
- City: Any location with variable climate
- Date range: 1-2 years
- Model: Compare Sine vs. Polynomial (2nd)

**What to look for**:
- Which model has higher R²
- Residual patterns indicating model suitability

## Tips & Best Practices

### Data Quality
- Longer time ranges provide more reliable fits
- At least 10 days of data required (365+ days recommended for sine)
- API may have gaps for very old dates or certain locations

### Model Selection
1. **Start with Sine** for seasonal analysis (most weather is cyclic)
2. **Use Linear** to detect overall trends
3. **Try Polynomial** only if Sine and Linear don't fit well
4. **Compare R² and RMSE** across models

### Troubleshooting

**"Unexpected API response structure"**
- Try a shorter date range
- Check internet connection
- Verify coordinates are valid

**Poor R² (<0.5)**
- Try a different model type
- Increase data range (more days)
- Check for data quality issues

**Sine fitting gives unrealistic period**
- Ensure you have at least 1 complete seasonal cycle (365+ days)
- Try increasing date range to 2-3 years

## Technical Details

### API Information
- **Source**: [Open-Meteo Archive API](https://archive-api.open-meteo.com/)
- **Data**: Daily temperature (max, min) and precipitation
- **Coverage**: Global, historical data from 1940-present
- **Rate limits**: Reasonable use allowed, no API key required

### File Structure
```
montreal/
├── vscode/
│   └── montreal_weather_sine_app.m    # Main application
├── tests/
│   └── testMontrealWeatherSineApp.m   # Unit tests
├── data/                               # Data files
└── README_sine_app.md                  # This file
```

## Testing

Run the test suite to verify functionality:

```matlab
% Navigate to tests directory
cd('c:\Users\ydebray\Downloads\montreal\tests')

% Run tests
results = runtests('testMontrealWeatherSineApp')
```

Tests include:
- Sine model fitting with synthetic data
- Linear regression accuracy
- Polynomial fitting
- R² calculation verification
- RMSE calculation verification

## Examples of Cities with Interesting Patterns

### Strong Seasonal Cycles (Sine Model)
- **Montreal, Canada** (45.50°N, -73.57°W): Cold winters, hot summers
- **Moscow, Russia** (55.76°N, 37.62°E): Extreme continental climate
- **Beijing, China** (39.90°N, 116.40°E): Four distinct seasons

### Mild Climates (Linear/Sine)
- **San Diego, USA** (32.72°N, -117.16°W): Stable year-round
- **Sydney, Australia** (-33.87°S, 151.21°E): Mild variations
- **Barcelona, Spain** (41.39°N, 2.16°E): Mediterranean climate

### Tropical (Small Amplitude Sine)
- **Singapore** (1.35°N, 103.82°E): Minimal seasonal variation
- **Mumbai, India** (19.08°N, 72.88°E): Monsoon patterns

## Future Enhancements

Potential additions:
- [ ] Fourier series for multiple harmonic components
- [ ] Humidity and wind speed analysis
- [ ] Comparison between multiple cities
- [ ] Export data and plots
- [ ] Climate zone classification
- [ ] Prediction/forecasting capability
- [ ] Integration with local weather station data

## Credits

**Author**: Created for Montreal weather data analysis  
**API**: Open-Meteo (https://open-meteo.com/)  
**License**: MIT (or as appropriate)

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Verify MATLAB version compatibility
3. Test with preset cities first
4. Review error messages carefully

## Citation

If you use this application in research or publications, please cite:

```
Montreal Weather Sine Fitting Application
MATLAB Application for Weather Data Analysis
https://github.com/yanndebray/montreal
```

## Version History

- **v1.0** (2025-11-11): Initial release
  - Sine, linear, and polynomial (2-4 degree) fitting
  - Multiple visualization tabs
  - Comprehensive statistics
  - Quick city selection
  - Custom date ranges

---

**Enjoy analyzing weather patterns! 🌤️📊**
