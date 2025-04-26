//
//  GearSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct GearSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @State private var errorMessage: String?
    @State private var warningMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if let warning = warningMessage {
                    Text(warning)
                        .foregroundColor(.orange)
                        .padding()
                } else {
                    contentView
                }
            }
            .navigationTitle("Select Gear")
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var contentView: some View {
        if let error = dataManager.errors["gear"] {
            return AnyView(
                Text("Error: \(error). Please ensure gear.json is present and correctly formatted.")
                    .foregroundColor(.red)
                    .padding()
            )
        } else if dataManager.gear.isEmpty {
            return AnyView(
                Text("Error: No gear data available. Please ensure gear.json contains valid gear entries.")
                    .foregroundColor(.red)
                    .padding()
            )
        } else {
            return AnyView(
                List {
                    ForEach(dataManager.gear, id: \.id) { item in
                        gearRow(for: item)
                    }
                }
            )
        }
    }

    private func gearRow(for item: Gear) -> some View {
        HStack {
            Text(item.name)
            if let cost = parseCost(item.cost) {
                Text("\(cost)¥")
                Button("Buy") {
                    if character.nuyen >= cost {
                        let newNuyen = character.nuyen - cost
                        if newNuyen < 0 {
                            errorMessage = "Error: Purchase would result in negative nuyen (\(newNuyen)¥). Please increase nuyen."
                        } else {
                            character.nuyen = newNuyen
                            character.gear[item.name, default: 0] += 1
                            if character.nuyen <= 100 {
                                warningMessage = "Warning: Only \(character.nuyen)¥ remaining! Consider acquiring more resources."
                            } else {
                                warningMessage = nil
                            }
                        }
                    } else {
                        errorMessage = "Error: Insufficient nuyen (\(character.nuyen)¥) to purchase \(item.name) (\(cost)¥). Please increase nuyen."
                    }
                }
                .disabled(character.nuyen < cost)
            } else {
                Text("Invalid Cost")
                    .foregroundColor(.red)
            }
        }
    }

    private func parseCost(_ cost: String?) -> Int? {
        guard let costString = cost else { return nil }
        // Remove commas and non-numeric characters, keeping digits
        let cleaned = costString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard let costValue = Int(cleaned), costValue >= 0 else {
            errorMessage = "Error: Invalid cost format for \(costString). Please check gear.json for valid numeric costs."
            return nil
        }
        return costValue
    }
}
