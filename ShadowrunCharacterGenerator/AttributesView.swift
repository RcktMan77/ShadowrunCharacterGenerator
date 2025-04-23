//
//  AttributesView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct AttributesView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    
    // Metatype attribute ranges (simplified; ideally parsed from metatypes.json)
    private let attributeRanges: [String: ClosedRange<Int>] = [
        "Human": 1...6,
        "Elf": 1...6, // Adjust based on metatypes.json (e.g., Charisma 3-8)
        "Dwarf": 1...6,
        "Ork": 1...6,
        "Troll": 1...6
    ]
    
    // Calculate effective attribute value (base + improvements)
    private func effectiveAttribute(_ attribute: String) -> Int {
        let base = character.attributes[attribute] ?? 1
        let bonuses = dataManager.improvements
            .filter { $0.type == "Attribute" && $0.target == attribute }
            .reduce(0) { $0 + $1.value }
        return base + bonuses
    }
    
    // Karma cost for upgrading an attribute (new rating × 5)
    private func upgradeCost(for attribute: String, to newValue: Int) -> Int {
        return newValue * 5
    }
    
    var body: some View {
        Section(header: Text(NSLocalizedString("Attributes", comment: "Section header"))) {
            ForEach(["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"], id: \.self) { attr in
                HStack {
                    Text(NSLocalizedString(attr, comment: "Attribute name"))
                    Spacer()
                    Text("Base: \(character.attributes[attr] ?? 1)")
                    Text("Effective: \(effectiveAttribute(attr))")
                    Button("Upgrade") {
                        let current = character.attributes[attr] ?? 1
                        let newValue = current + 1
                        let cost = upgradeCost(for: attr, to: newValue)
                        let range = attributeRanges[character.metatype] ?? (1...6)
                        
                        if character.karma >= cost && range.contains(newValue) {
                            character.karma -= cost
                            character.attributes[attr] = newValue
                        }
                    }
                    .disabled(character.karma < upgradeCost(for: attr, to: (character.attributes[attr] ?? 1) + 1) ||
                              !(attributeRanges[character.metatype] ?? (1...6)).contains((character.attributes[attr] ?? 1) + 1))
                }
            }
        }
    }
}

struct AttributesView_Previews: PreviewProvider {
    static var previews: some View {
        AttributesView(character: .constant(Character(
            name: "Test",
            metatype: "Human",
            attributes: ["Body": 3, "Agility": 4],
            skills: [:],
            karma: 20,
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
            martialArts: []
        )))
        .environmentObject(DataManager())
    }
}
