//
//  RangesView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct RangesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var sortOption: SortOption = .name
    @State private var errorMessage: String?
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Name"
        case maxRange = "Max Range"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                if let rangesError = dataManager.errors["ranges"] {
                    Text(rangesError)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Picker("Sort By", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    let groupedRanges = groupRanges()
                    ForEach(groupedRanges.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category)) {
                            ForEach(groupedRanges[category] ?? [], id: \.name) { range in
                                VStack(alignment: .leading) {
                                    Text(range.name)
                                        .font(.headline)
                                    HStack {
                                        Text("Short: \(formatRange(range.short)) m")
                                        Spacer()
                                        Text("Medium: \(formatRange(range.medium)) m")
                                    }
                                    HStack {
                                        Text("Long: \(formatRange(range.long)) m")
                                        Spacer()
                                        Text("Extreme: \(formatRange(range.extreme)) m")
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Weapon Ranges")
            }
            .onAppear {
                if dataManager.ranges.isEmpty && dataManager.errors["ranges"] == nil {
                    errorMessage = "No ranges available."
                }
            }
        }
    }
    
    private func formatRange(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleaned.isEmpty ? "N/A" : cleaned
    }
    
    private func groupRanges() -> [String: [Range]] {
        var grouped: [String: [Range]] = [:]
        let sortedRanges = dataManager.ranges.sorted { range1, range2 in
            switch sortOption {
            case .name:
                return range1.name < range2.name
            case .maxRange:
                return range1.maxRange > range2.maxRange
            }
        }
        
        for range in sortedRanges {
            let category = range.category
            grouped[category, default: []].append(range)
        }
        
        return grouped
    }
}

struct RangesView_Previews: PreviewProvider {
    static var previews: some View {
        RangesView()
            .environmentObject({
                let dm = DataManager.shared
                dm.ranges = [
                    Range(name: "Light Pistol", min: "0", short: "5", medium: "15", long: "30", extreme: "50"),
                    Range(name: "Assault Rifle", min: "0", short: "25", medium: "150", long: "350", extreme: "550")
                ]
                return dm
            }())
    }
}
