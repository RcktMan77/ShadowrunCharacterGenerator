//
//  SkillsView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct SkillsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @State private var showingSpecializationPicker = false
    @State private var selectedSkill: String?
    
    // Calculate effective skill value (base + improvements)
    private func effectiveSkill(_ skill: String) -> Int {
        let base = character.skills[skill] ?? 0
        let bonuses = dataManager.improvements
            .filter { $0.type == "Skill" && $0.target == skill }
            .reduce(0) { $0 + $1.value }
        return base + bonuses
    }
    
    // Get linked attribute for a skill
    private func linkedAttribute(for skill: String) -> String {
        dataManager.skills.first { $0.name == skill }?.attribute ?? "Unknown"
    }
    
    // Karma cost for upgrading a skill (new rating × 2)
    private func upgradeCost(for skill: String, to newValue: Int) -> Int {
        return newValue * 2
    }
    
    // Specialization cost (fixed at 7 Karma)
    private let specializationCost = 7
    
    var body: some View {
        Section(header: Text(NSLocalizedString("Skills", comment: "Section header"))) {
            if character.skills.isEmpty {
                Text(NSLocalizedString("No skills assigned", comment: "Empty skills message"))
            } else {
                ForEach(character.skills.sorted(by: { $0.key < $1.key }), id: \.key) { skill, value in
                    HStack {
                        Text(NSLocalizedString(skill, comment: "Skill name"))
                        Spacer()
                        Text("Linked: \(linkedAttribute(for: skill))")
                        Text("Base: \(value)")
                        Text("Effective: \(effectiveSkill(skill))")
                        Button("Upgrade") {
                            let newValue = value + 1
                            let cost = upgradeCost(for: skill, to: newValue)
                            if character.karma >= cost && newValue <= 12 {
                                character.karma -= cost
                                character.skills[skill] = newValue
                            }
                        }
                        .disabled(character.karma < upgradeCost(for: skill, to: value + 1) || value >= 12)
                        Button("Specialize") {
                            selectedSkill = skill
                            showingSpecializationPicker = true
                        }
                        .disabled(character.karma < specializationCost)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSpecializationPicker) {
            SpecializationPickerView(character: $character, skill: selectedSkill ?? "") {
                showingSpecializationPicker = false
            }
        }
    }
}

// Subview for selecting a specialization
struct SpecializationPickerView: View {
    @Binding var character: Character
    let skill: String
    let onDismiss: () -> Void
    @State private var specialization: String = ""
    
    var body: some View {
        Form {
            TextField(NSLocalizedString("Specialization", comment: "Specialization input"), text: $specialization)
            Button(NSLocalizedString("Add Specialization", comment: "Button")) {
                if !specialization.isEmpty && character.karma >= 7 {
                    character.karma -= 7
                    // Store specialization (simplified; ideally add to Character struct)
                    print("Added specialization \(specialization) for \(skill)")
                    onDismiss()
                }
            }
            .disabled(specialization.isEmpty || character.karma < 7)
            Button(NSLocalizedString("Cancel", comment: "Button")) {
                onDismiss()
            }
        }
        .navigationTitle(NSLocalizedString("Add Specialization", comment: "Title"))
    }
}

struct SkillsView_Previews: PreviewProvider {
    static var previews: some View {
        SkillsView(character: .constant(Character(
            name: "Test",
            metatype: "Human",
            attributes: ["Body": 3, "Agility": 4],
            skills: ["Pistols": 5, "Stealth": 3],
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
            martialArts: [],
            sourcebooks: []
        )))
        .environmentObject(DataManager())
    }
}
