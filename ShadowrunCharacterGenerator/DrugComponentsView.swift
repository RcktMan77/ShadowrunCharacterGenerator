//
//  DrugComponentsView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct DrugComponentsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                contentView
                Section {
                    Text("Nuyen Remaining: \(character.nuyen)¥")
                        .padding()
                }
            }
            .navigationTitle("Drug Components")
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
        if let error = dataManager.errors["drugcomponents"] {
            return AnyView(
                Text("Error: \(error). Please ensure drugcomponents.json is present and correctly formatted.")
                    .foregroundColor(.red)
                    .padding()
            )
        } else if dataManager.drugComponents.isEmpty {
            return AnyView(
                Text("Error: No drug components data available. Please ensure drugcomponents.json contains valid drug component entries.")
                    .foregroundColor(.red)
                    .padding()
            )
        } else {
            return AnyView(
                List {
                    Section(header: Text("Drug Components")) {
                        ForEach(dataManager.drugComponents, id: \.id) { component in
                            drugComponentRow(for: component)
                        }
                    }
                }
            )
        }
    }

    private func drugComponentRow(for component: DrugComponent) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(component.name)
                    .font(.headline)
                Text("Effect: \(effectSummary(for: component))")
                Text("Availability: \(component.availability)")
            }
            Spacer()
            if let cost = parseCost(component.cost) {
                Text("\(cost)¥")
                Button("Buy") {
                    if character.nuyen >= cost {
                        character.nuyen -= cost
                        character.gear[component.name, default: 0] += 1
                    } else {
                        errorMessage = "Error: Insufficient nuyen (\(character.nuyen)¥) to purchase \(component.name) (\(cost)¥). Please increase nuyen."
                    }
                }
                .disabled(character.nuyen < cost)
            } else {
                Text("Invalid Cost")
                    .foregroundColor(.red)
            }
        }
    }

    private func effectSummary(for component: DrugComponent) -> String {
        guard let effects = component.effects, !effects.isEmpty else {
            return "None"
        }
        return effects.map { effect in
            var parts: [String] = []
            if let attributes = effect.attribute, !attributes.isEmpty {
                let attrSummary = attributes.map { "\($0.name): \($0.value)" }.joined(separator: ", ")
                parts.append(attrSummary)
            }
            if let quality = effect.quality {
                parts.append(quality.name)
            }
            if let crashdamage = effect.crashdamage {
                parts.append("Crash Damage: \(crashdamage)")
            }
            if let info = effect.info {
                parts.append(info)
            }
            if let limits = effect.limit, !limits.isEmpty {
                let limitSummary = limits.map { "\($0.name) Limit: \($0.value)" }.joined(separator: ", ")
                parts.append(limitSummary)
            }
            return parts.isEmpty ? "Level \(effect.level)" : parts.joined(separator: "; ")
        }.joined(separator: "; ")
    }

    private func parseCost(_ cost: String?) -> Int? {
        guard let costString = cost else {
            errorMessage = "Error: Missing cost for drug component. Please check drugcomponents.json for valid cost values."
            return nil
        }
        // Remove commas and non-numeric characters, keeping digits
        let cleaned = costString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard let costValue = Int(cleaned), costValue >= 0 else {
            errorMessage = "Error: Invalid cost format for \(costString). Please check drugcomponents.json for valid numeric costs."
            return nil
        }
        return costValue
    }
}

struct DrugComponentsView_Previews: PreviewProvider {
    static var previews: some View {
        DrugComponentsView(character: .constant(Character(
            name: "Test",
            metatype: "Human",
            priority: nil,
            attributes: [:],
            skills: [:],
            specializations: [:],
            karma: 0,
            nuyen: 1000,
            gear: [:],
            qualities: [:],
            contacts: [:],
            spells: [],
            complexForms: [],
            powers: [:],
            mentor: nil,
            tradition: nil,
            metamagic: [],
            echoes: [],
            licenses: [:],
            lifestyle: nil,
            martialArts: [],
            sourcebooks: []
        )))
        .environmentObject({
            let dm = DataManager()
            dm.drugComponents = [
                DrugComponent(
                    id: "1",
                    name: "Stimulant",
                    category: "Chemical",
                    effects: [
                        Effect(
                            level: "1",
                            attribute: [Attribute(name: "Reaction", value: "+1")],
                            quality: nil,
                            crashdamage: nil,
                            info: nil,
                            limit: nil
                        )
                    ],
                    availability: "6",
                    cost: "100",
                    rating: "1",
                    threshold: "2",
                    source: "Core",
                    page: "123"
                )
            ]
            return dm
        }())
    }
}
