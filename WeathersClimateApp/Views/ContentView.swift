//
//  ContentView.swift
//  WeathersClimateApp
//
//  Created by Mukund Madhav on 01/11/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var viewModel: weathersViewModel = weathersViewModel()
    @State var showError: Bool = false
    @State var selectedDate: Date = Date()
    

    var dateRange: ClosedRange<Date> {
        let today = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let futureDate = Calendar.current.date(byAdding: .day, value: 6, to: today)!
        return pastDate...futureDate
    }
    
    // --- NEW: Define the grid layout (2 columns) ---
    private let gridItems = [
        GridItem(.adaptive(minimum: 160), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.condition.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        DatePicker(selection: $selectedDate,
                                                           in: dateRange,
                                                           displayedComponents: .date) {
                                                    
                                                    // 1. Use the DatePicker's LABEL for the icon
                                                    Image(systemName: "calendar")
                                                        .foregroundStyle(.white)
                                                        .fontWeight(.bold)
                                                        .font(.title)
                                                }
                                                    .datePickerStyle(.compact)
                                                    .tint(.white) // 2. Makes the date text white
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 10)
                                                    .glassEffect(.clear, in: Capsule())
                        
                        Weather //
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                        
                        
                        LazyVGrid(columns: gridItems, spacing: 20) {
                            
                            WeatherDetailBlock(
                                icon: "drop.fill",
                                title: "Precipitation",
                                value: "\(String(format: "%.1f", viewModel.precipitationSum ?? 0)) mm",
                                description: "Total for the day"
                            )
                            
                            WeatherDetailBlock(
                                icon: "humidity.fill",
                                title: "Humidity",
                                value: "\(viewModel.humidity ?? 0)%",
                                description: "Average for the day"
                            )
                            
                            WeatherDetailBlock(
                                icon: "wind",
                                title: "Wind",
                                value: "\(String(format: "%.1f", viewModel.windSpeedMax ?? 0)) km/h",
                                description: "Max speed"
                            )
                            
                            WeatherDetailBlock(
                                icon: "lungs.fill", // or "aqi.medium"
                                title: "PM2.5",
                                value: "\(String(format: "%.1f", viewModel.pm25Max ?? 0)) µg/m³",
                                description: "Max concentration"
                            )
                            
                            WeatherDetailBlock(
                                icon: "lungs.fill", // or "aqi.high"
                                title: "PM10",
                                value: "\(String(format: "%.1f", viewModel.pm10Max ?? 0)) µg/m³",
                                description: "Max concentration"
                            )
                            
                            WeatherDetailBlock(
                                icon: "carbon.dioxide.cloud.fill",
                                title: "CO₂",
                                value: "\(String(format: "%.0f", viewModel.carbonDioxideMax ?? 0)) ppm",
                                description: "Max concentration"
                            )
                        

                        }
                        PlantCalculatorBlock(viewModel: viewModel)
                        
                    }
                    .padding(.horizontal) // Pad the whole VStack
                }
                .refreshable {
                    Task {
                        await viewModel.fetchQualityData(selectedDate)
                        await viewModel.fetchWeatherData(selectedDate)
                    }
                }
            }
            .onChange(of: selectedDate) {
                Task {
                    await viewModel.fetchWeatherData(selectedDate)
                    await viewModel.fetchQualityData(selectedDate)
                }
            }
            
        }
        
        .task {
            // --- Remember to add `past_days=1` to your ViewModel URLs! ---
            await viewModel.fetchQualityData(selectedDate)
            await viewModel.fetchWeatherData(selectedDate)
        }
    }
    
  
    var Weather: some View{
        HStack(spacing: 20){
            
            // MARK: - Weather Icon
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 110 , height: 110)
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                
                Image(systemName: viewModel.condition.symbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90 , height: 90)
                    .symbolRenderingMode(.multicolor)
                    .shadow(radius: 5) //
            }
            .frame(width: 110, height: 110)
            
            Spacer()
            
            // MARK: - Temperatures
            VStack(alignment: .trailing, spacing: 4) {
                
                
                Text("\(Int(viewModel.maxTemp ?? 0))°")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    // Your red gradient, but adjusted for better contrast
                    .foregroundStyle(LinearGradient(colors: [.white, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)

             
                Text("\(Int(viewModel.minTemp ?? 0))°")
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                    // Your blue gradient, but adjusted
                    .foregroundStyle(LinearGradient(colors: [.white.opacity(0.9), .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
            }
            .padding(.trailing, 10)
            
        }.padding()
    }
    
}


struct WeatherDetailBlock: View {
    var icon: String
    var title: String
    var value: String
    var description: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Icon + Title
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                Text(title.uppercased())
                    .font(.system(.caption, design: .rounded)) // Looks more like Apple's font
                    .foregroundStyle(.secondary)
            }
            
            // Main Value
            Text(value)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
         
            if let description {
                Text(description)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(minHeight: 160, alignment: .topLeading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
    }
    
}

struct PlantCalculatorBlock: View {
    
    @Bindable var viewModel: weathersViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 110, height: 110)
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                
                Image(systemName: viewModel.selectedPlant.plantSymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.green)
                    .shadow(radius: 5)
            }
            .frame(width: 110, height: 110)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                
                Picker("Select Plant:", selection: $viewModel.selectedPlantID) {
                    ForEach(viewModel.availablePlants) { plant in
                        Text(plant.plantName)
                            .tag(plant.id)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .trailing)

                Spacer()
                
                // --- ⭐️ TEXT FIX 1 ⭐️ ---
                Text("**\(viewModel.recommendedQuantity) plants** needed")
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
                
                // --- ⭐️ TEXT FIX 2 ⭐️ ---
                Text("Est. O₂: **\(viewModel.o2Emitted) L/day**")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.trailing)
                    .padding(.top, 2)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            .padding(.trailing, 10)
            
        }
        .padding()
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ContentView()
}
