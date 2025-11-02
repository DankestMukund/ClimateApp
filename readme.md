⚛️ ClimateGuard: EVS Weather & CO₂ Solution
ClimateGuard is a comprehensive iOS application built with SwiftUI for an Environmental Studies (EVS) project. It goes beyond a simple weather app by directly connecting the problem of Greenhouse Gas (GHG) monitoring with a tangible, real-world solution—carbon sequestration through indoor plants.

The app provides real-time weather and air quality data, with a special focus on monitoring live CO₂ levels. It then uses this live data to power a dynamic calculator that shows the user exactly how many common indoor plants are needed to offset the carbon in a standard room, fulfilling key EVS objectives.

Live Weather & AQI    Interactive Date Picker    Dynamic Plant Calculator
<img src="assets/IMG_0353.jpeg" width="250">    <img src="assets/IMG_0355.jpeg" width="250">    <img src="assets/IMG_0354.jpeg" width="250">
[!NOTE] This is a complete EVS project that successfully fulfills all required objectives, from app development and GHG monitoring to carbon sequestration and O₂ emission calculation.

🎯 EVS Project Objectives Fulfilled
This application was built to satisfy the following EVS project requirements:
✅ App development of rainfall predictions, temperature, humidity, wind, SPM etc. per day
The app's main dashboard displays all of this: Temperature (Min/Max), Precipitation, Humidity, and Wind speed.
"SPM" (Suspended Particulate Matter) is monitored via the PM2.5 and PM10 blocks.
The DatePicker allows users to get this data for any day in the 7-day forecast.
✅ Development of predictions model through software like monitoring of GHG's from different sources
The app serves as the "software for monitoring."
It monitors CO₂ (Carbon Dioxide), a primary Greenhouse Gas (GHG).
It uses a professional-grade prediction model (the Open-Meteo API) to source this data.
✅ Carbon Sequestration
This is the core feature of the PlantCalculatorBlock.
The app directly addresses carbon sequestration by linking the monitored CO₂ level to the number of plants required to absorb it.
✅ App generation for CO2 absorbance and O2 emissions by different indoor plants
The final app module is a "CO2 absorbance" calculator.
It dynamically calculates the number of plants needed based on live CO₂ data.
It displays the estimated O₂ emissions from that quantity of plants.
A Picker allows the user to select from different indoor plants, each with a unique absorption rate.
🌦️ Features
Dynamic Weather Dashboard: Clean, responsive UI that shows the most important weather data at a glance.
7-Day Forecast: A compact, glass-style DatePicker allows users to select a day and instantly update all data modules.
Real-Time Air Quality: Monitors PM2.5, PM10, and—most importantly—CO₂ levels.
Dynamic Backgrounds: The gradient background changes based on the weather condition (e.g., cloudy, sunny, thunderstorm).
CO₂ Sequestration Calculator: The app's core scientific feature. It reads the live CO₂ ppm value and calculates the number of plants needed to clean a room.
Plant-Specific Data: The user can pick from different plants (Snake Plant, Pothos, etc.), and the app will recalculate the quantity based on that plant's specific CO₂ absorption rate.
O₂ Emission Estimates: Complements the CO₂ calculation by showing the estimated oxygen produced by the recommended number of plants.
MVVM Architecture: Built on a modern, observable ViewModel to separate logic from the view.
🔬 Core Logic: The CO₂ Calculator
The app's most powerful feature is its ability to connect an abstract air quality number (ppm) to a physical, actionable number (plants needed). This is not a simple guess; it's based on a scientific calculation.

The challenge is that the API provides CO₂ as a concentration (parts per million), but plants absorb a mass (grams per day). The app bridges this gap:

1. Calculate CO₂ Mass in a Room First, we convert the ppm concentration into a total mass of CO₂ (in grams) within a standard-sized room.

Swift
// In ViewModel.swift

// Get the live CO2 concentration from the API
let co2ConcentrationPPM = self.carbonDioxideMax ?? 0.0

// Define our constants
let roomVolumeM3 = 32.6 // Aprox 12x12x8 ft room
let co2DensityG_Per_M3 = 1980.0 // Density of CO2 in grams/m³

// The formula:
let totalCO2MassInRoomG = roomVolumeM3 * (co2ConcentrationPPM / 1_000_000.0) * co2DensityG_Per_M3
2. Calculate Plants Needed Next, we get the absorption rate for the selected plant (e.g., "Pothos" absorbs 5.2 g/day) and divide the total CO₂ mass by that rate. We use ceil() to round up, as you can't have a fraction of a plant.

Swift
// In ViewModel.swift

// Get the Rate (Plant's absorption)
let plantAbsorptionRate = self.selectedPlant.plantAbsorption

// The final calculation: Int(Goal / Rate)
let quantity = Int(ceil(totalCO2MassInRoomG / plantAbsorptionRate))

// This returns the number of plants needed
return quantity
This calculation runs instantly every time the date or the selected plant is changed, providing a dynamic and scientifically-grounded solution.

📱 App Gallery
Thunderstorm (Nov 1)    Cloudy (Nov 2)    Future Forecast (Nov 6)
<img src="assets/IMG_0357.jpeg" width="250">    <img src="assets/IMG_0353.jpeg" width="250">    <img src="assets/IMG_0356.jpeg" width="250">
🛠️ Tech Stack & Architecture
Framework: SwiftUI
State Management: @Observable (Swift's modern observation framework)
Architecture: MVVM (Model-View-ViewModel)
Networking: Async/Await with URLSession
Data Models: Codable structs for parsing JSON
Design: Custom "glassmorphism" effect (.glassEffect), dynamic LinearGradient backgrounds
API: Open-Meteo (used for both Weather Forecast and Air Quality APIs)
🚀 How to Run
Clone the repository:
Bash
git clone https://github.com/DankestMukund/ClimateApp.git
Open the .xcodeproj file in Xcode.
Build and run on a simulator or a physical device.
👏 Acknowledgements
This project is powered by the free and open-source Open-Meteo API for all weather and air quality data.
