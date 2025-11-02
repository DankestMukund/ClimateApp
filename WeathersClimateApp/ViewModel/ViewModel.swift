//
//  ViewModel.swift
//  WeathersClimateApp
//
//  Created by Mukund Madhav on 01/11/25.
//

import Foundation

@Observable
class weathersViewModel {
    var airQuality: MainAirQuality?
    var weatherData: MainWeatherQuality?
    let availablePlants: [CarbonPlant] = [
            CarbonPlant(id: UUID(), plantName: "Snake Plant", plantAbsorption: 6.5, plantSymbol: "leaf.fill"),
            CarbonPlant(id: UUID(), plantName: "Spider Plant", plantAbsorption: 5.8, plantSymbol: "laurel.leading"),
            CarbonPlant(id: UUID(), plantName: "Pothos", plantAbsorption: 5.2, plantSymbol: "leaf.arrow.triangle.circlepath"),
            CarbonPlant(id: UUID(), plantName: "Peace Lily", plantAbsorption: 7.1, plantSymbol: "camera.macro")
        ]
    var selectedPlantID: UUID
        
        var selectedPlant: CarbonPlant {
            availablePlants.first { $0.id == selectedPlantID } ?? availablePlants[0]
        }
    
    let qualityurl = "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=22.5626&longitude=88.363&hourly=pm10,pm2_5,carbon_monoxide,carbon_dioxide&timezone=Asia/Kolkata&forecast_days=7&past_days=1&domains=cams_global"

    let weatherurl = "https://api.open-meteo.com/v1/forecast?latitude=22.5626&longitude=88.363&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,weather_code&hourly=relative_humidity_2m&timezone=Asia/Kolkata&forecast_days=7&past_days=1"
    
    var condition: WeatherCondition = .sunny
        
    init() {
        self.selectedPlantID = availablePlants.first?.id ?? UUID()
    }

    // --- 3. UI PROPERTIES ---
    var errorMessage: String? = nil
    var time: String? = nil
    var minTemp: Int? = nil
    var maxTemp: Int? = nil
    var precipitationSum: Double? = nil
    var humidity: Int? = nil // <-- Changed to Int for the average
    var windSpeedMax: Double? = nil
    var pm10Max: Double? = nil
    var pm25Max: Double? = nil
    var carbonDioxideMax: Double? = nil
    var carbonMonoxideMax: Double? = nil
    
    var recommendedQuantity: Int {
            let co2ConcentrationPPM = self.carbonDioxideMax ?? 0.0
            let roomVolumeM3 = 32.6 // Aprox 12x12x8 ft room
            let co2DensityG_Per_M3 = 1980.0 // Density of CO2
            
            // Total CO2 mass in the room
            let totalCO2MassInRoomG = roomVolumeM3 * (co2ConcentrationPPM / 1_000_000.0) * co2DensityG_Per_M3
            
            let plantAbsorptionRate = self.selectedPlant.plantAbsorption
            
            guard plantAbsorptionRate > 0 else { return 0 }
            
            // Final calculation (rounds up to the nearest whole plant)
            return Int(ceil(totalCO2MassInRoomG / plantAbsorptionRate))
        }
    
    var o2Emitted: String {
            let o2PerPlant: Double = switch self.selectedPlant.plantName {
                case "Peace Lily": 1.8
                case "Snake Plant": 1.2
                case "Spider Plant": 1.5
                case "Pothos": 1.3
                default: 1.0
            }
            
            let totalO2 = Double(self.recommendedQuantity) * o2PerPlant
            return String(format: "%.1f", totalO2)
        }
    // --- Helper function to convert Date to the "YYYY-MM-DD" string ---
    private func formattedDateString(from date: Date) -> String {
        return date.formatted(.iso8601.year().month().day())
    }
    
    @MainActor
    func fetchQualityData(_ selectedDate: Date) async {
        self.errorMessage = nil
        let dateString = formattedDateString(from: selectedDate)
        
        do {
            airQuality = try await NetworkManager.shared.fetchData(from: qualityurl)
    
            guard let hourlyData = airQuality?.hourly else {
                print("Hourly air data is nil after fetch.")
                return
            }

            guard let startIndex = hourlyData.time.firstIndex(where: { $0.starts(with: dateString) }) else {
                print("Could not find air quality for date: \(dateString)")
                return
            }
            
            let endIndex = startIndex + 23
            
            guard hourlyData.pm25.count > endIndex else {
                print("Hourly air data array is not long enough.")
                return
            }
            
            // Use .compactMap { $0 } to safely remove 'nil' values from [Double?]
            let pm10Slice = hourlyData.pm10[startIndex...endIndex].compactMap { $0 }
            let pm25Slice = hourlyData.pm25[startIndex...endIndex].compactMap { $0 }
            let co2Slice = hourlyData.carbonDioxide[startIndex...endIndex].compactMap { $0 }
            let coSlice = hourlyData.carbonMonoxide[startIndex...endIndex].compactMap { $0 }
            
            // Now .max() is safe to call
            self.pm10Max = pm10Slice.max()
            self.pm25Max = pm25Slice.max()
            self.carbonDioxideMax = co2Slice.max()
            self.carbonMonoxideMax = coSlice.max()
            
            print("Successfully set max air quality values for \(dateString)")
            
        }
        catch{
            print("Failed to fetch air quality: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    
    }
    
    @MainActor
    func fetchWeatherData(_ selectedDate: Date) async {
        self.errorMessage = nil
        let dateString = formattedDateString(from: selectedDate)
        
        do {
            weatherData = try await NetworkManager.shared.fetchData(from: weatherurl)
            
            guard let dailyData = weatherData?.daily, let hourlyData = weatherData?.hourly else {
                print("Weather data is nil.")
                return
            }

            // --- A. Get Daily Data ---
            guard let dailyIndex = dailyData.time.firstIndex(of: dateString) else {
                print("Could not find daily weather for \(dateString)")
                return
            }
            
            // Use '?? 0' to safely unwrap optionals from your model
            self.time = dailyData.time[dailyIndex]
            self.maxTemp = Int(dailyData.maxTemp[dailyIndex] ?? 0)
            self.minTemp = Int(dailyData.minTemp[dailyIndex] ?? 0)
            self.precipitationSum = dailyData.precipitation[dailyIndex] ?? 0
            self.windSpeedMax = dailyData.maxWindSpeed[dailyIndex] ?? 0
            
            let code = dailyData.weatherCode[dailyIndex] ?? 0
            self.condition = convert(code: code)
            
            // --- B. Get Hourly Humidity ---
            guard let hourlyStartIndex = hourlyData.time.firstIndex(where: { $0.starts(with: dateString) }) else {
                print("Could not find hourly humidity for \(dateString)")
                return
            }
            
            let hourlyEndIndex = hourlyStartIndex + 23
            guard hourlyData.relativeHumidity.count > hourlyEndIndex else { return }

            // Use .compactMap { $0 } to remove 'nil' values
            let humiditySlice = hourlyData.relativeHumidity[hourlyStartIndex...hourlyEndIndex].compactMap { $0 }
            
            if !humiditySlice.isEmpty {
                let averageHumidity = humiditySlice.reduce(0, +) / Double(humiditySlice.count)
                self.humidity = Int(averageHumidity)
            } else {
                self.humidity = nil // No valid data
            }
            
            print("Successfully set weather values for \(dateString)")

        } catch {
            print("Failed to fetch weather: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    private func convert(code: Int) -> WeatherCondition {
        switch code {
        case 0: return .sunny
        case 1, 2, 3, 45, 48: return .cloudy
        case 51, 53, 55, 61, 63, 65, 80, 81, 82: return .raining
        case 95, 96, 99: return .thunderstorm
        default: return .cloudy
        }
        
       
    }
    private func showPlant(carbon: Int) {
        
    }
}
