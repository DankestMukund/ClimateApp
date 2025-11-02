//
//  WeathersCondition.swift
//  WeathersClimateApp
//
//  Created by Mukund Madhav on 01/11/25.
//

import Foundation
import SwiftUI
enum WeatherCondition {
    case sunny
    case cloudy
    case raining
    case thunderstorm
    
   
    var symbolName: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
                
        case .cloudy:
            return "cloud.fill"
        case .raining:
            return "cloud.rain.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        }
    }
    var gradient: LinearGradient {
        
        let top = UnitPoint.top
        let bottom = UnitPoint.bottom
        
        switch self {
        case .sunny:

            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.6, blue: 1.0), Color.blue],
                startPoint: top, endPoint: bottom
            )
        case .cloudy:

            return LinearGradient(
                colors: [Color.gray.opacity(0.7), Color.blue.opacity(0.5)],
                startPoint: top, endPoint: bottom
            )
        case .raining:
   
            return LinearGradient(
                colors: [Color.gray, Color.blue.opacity(0.6)],
                startPoint: top, endPoint: bottom
            )
        case .thunderstorm:

            return LinearGradient(
                colors: [Color(white: 0.2), Color.gray.opacity(0.8)],
                startPoint: top, endPoint: bottom
            )
        }
    }
}



