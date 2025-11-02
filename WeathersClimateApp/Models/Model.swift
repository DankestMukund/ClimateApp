// FILE: OpenMeteoResponse.swift

import Foundation


class MainWeatherQuality: Codable {
    let daily: dailyWeatherQuality
    let hourly: hourlyWeatherQuality
}

struct dailyWeatherQuality: Codable {
    let time: [String]
    let weatherCode: [Int?]
    let maxTemp: [Double?]
    let minTemp: [Double?]
    let precipitation: [Double?]
    let maxWindSpeed: [Double?]
    
    enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case maxTemp = "temperature_2m_max"
            case minTemp = "temperature_2m_min"
            case precipitation = "precipitation_sum"
            case maxWindSpeed = "wind_speed_10m_max"
    }
}
struct hourlyWeatherQuality: Codable {
    let time: [String]
    let relativeHumidity: [Double?]
    
    enum CodingKeys: String, CodingKey {
            case time
            case relativeHumidity = "relative_humidity_2m"
    }
}
///Air Quality
///

class MainAirQuality: Codable {
    let hourly: AirQuality
    
}
class AirQuality: Codable {
    let time: [String]
    let pm10: [Double?]
    let pm25: [Double?]
    let carbonDioxide: [Double?]
    let carbonMonoxide: [Double?]
    
    enum CodingKeys: String, CodingKey {
        case time
        case pm10
        case pm25 = "pm2_5" 
        case carbonDioxide = "carbon_dioxide"
        case carbonMonoxide = "carbon_monoxide"
    }
}

struct CarbonPlant: Identifiable {
    var id: UUID
     var plantName: String
     var plantAbsorption: Double
     var plantSymbol: String
    
}
