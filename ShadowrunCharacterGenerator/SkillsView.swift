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
    @State private var errorMessage: String?
    
    private func linkedAttribute(for skill: String) -> String {
        dataManager.skills.first { $0.name == skill }?.attribute ?? "Unknown"
    }
    
    private func upgradeCost(for skill: String, to newValue: Int) -> Int {
        return newValue * 2
    }
    
    private let specializationCost = 7
    private let maxSkillRating = 6 // Default Shadowrun 5e limit
    
    var body: some View {
        NavigationStack {
            Form {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Section(header: Text("Skills")) {
                    if character.skills.isEmpty {
                        Text("No skills assigned")
                    } else {
                        ForEach(character.skills.sorted(by: { $0.key < $1.key }), id: \.self.key) { skill, value in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(skill)
                                    if let spec = character.specializations[skill] {
                                        Text("Spec: \(spec)")
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Text("Linked: \(linkedAttribute(for: skill))")
                                Text("Value: \(value)")
                                Button("Upgrade") {
                                    let newValue = value + 1
                                    let cost = upgradeCost(for: skill, to: newValue)
                                    if character.karma >= cost && newValue <= maxSkillRating {
                                        character.karma -= cost
                                        character.skills[skill] = newValue
                                    }
                                }
                                .disabled(character.karma < upgradeCost(for: skill, to: value + 1) || value >= maxSkillRating)
                                Button("Specialize") {
                                    selectedSkill = skill
                                    showingSpecializationPicker = true
                                }
                                .disabled(character.karma < specializationCost || character.specializations[skill] != nil)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Skills")
            .sheet(isPresented: $showingSpecializationPicker) {
                SpecializationPickerView(
                    character: $character,
                    skill: selectedSkill ?? "",
                    onDismiss: { showingSpecializationPicker = false }
                )
            }
            .onAppear {
                if dataManager.skills.isEmpty {
                    errorMessage = "Failed to load skills data."
                }
            }
        }
    }
}

struct SpecializationPickerView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let skill: String
    let onDismiss: () -> Void
    @State private var specialization: String = ""
    @State private var errorMessage: String?
    
    private var availableSpecializations: [String] {
        dataManager.skills.first { $0.name == skill }?.specs ?? []
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Picker("Specialization", selection: $specialization) {
                    Text("Select Specialization").tag("")
                    ForEach(availableSpecializations, id: \.self) { spec in
                        Text(spec).tag(spec)
                    }
                }
                .pickerStyle(.menu)
                Button("Add Specialization") {
                    if !specialization.isEmpty && character.karma >= 7 {
                        character.karma -= 7
                        character.specializations[skill] = specialization
                        onDismiss()
                    }
                }
                .disabled(specialization.isEmpty || character.karma < 7)
                Button("Cancel") {
                    onDismiss()
                }
            }
            .navigationTitle("Add Specialization")
            .onAppear {
                if availableSpecializations.isEmpty {
                    errorMessage = "No specializations available for \(skill)."
                }
            }
        }
    }
}

struct SkillsView_Previews: PreviewProvider {
    static var previews: some View {
        SkillsView(character: .constant(Character(
            name: "Test",
            metatype: "Human",
            priority: nil,
            attributes: ["Body": 3, "Agility": 4],
            skills: ["Pistols": 5, "Stealth": 3],
            specializations: ["Pistols": "Revolvers"],
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
        .environmentObject({
            let dm = DataManager.shared
            dm.skills = [
                Skill(
                    id: "1",
                    name: "Pistols",
                    attribute: "Agility",
                    category: "Combat Active",
                    default: "True",
                    skillgroup: nil,
                    specs: ["Revolvers", "Semi-Automatics"],
                    source: "SR5",
                    page: "130",
                    exotic: nil,
                    requiresflymovement: nil,
                    requiresgroundmovement: nil,
                    requiresswimmovement: nil
                ),
                Skill(
                    id: "2",
                    name: "Stealth",
                    attribute: "Agility",
                    category: "Physical Active",
                    default: "True",
                    skillgroup: "Stealth",
                    specs: ["Sneaking", "Disguise"],
                    source: "SR5",
                    page: "133",
                    exotic: nil,
                    requiresflymovement: nil,
                    requiresgroundmovement: nil,
                    requiresswimmovement: nil
                )
            ]
            return dm
        }())
    }
}
