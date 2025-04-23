//
//  MagicSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct MagicSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    @State private var selectedSpells: [String] = []
    @State private var selectedPowers: [String: Double] = [:]
    @State private var selectedComplexForms: [String] = []
    @State private var selectedMentor: String?
    @State private var selectedTradition: String?
    
    var body: some View {
        Form {
            Section("Spells") {
                ForEach(dataManager.spells, id: \.name) { spell in
                    Button(action: {
                        if selectedSpells.contains(spell.name) {
                            selectedSpells.removeAll { $0 == spell.name }
                        } else {
                            selectedSpells.append(spell.name)
                        }
                    }) {
                        Text(spell.name)
                            .foregroundColor(selectedSpells.contains(spell.name) ? .blue : .primary)
                    }
                }
            }
            
            Section("Adept Powers") {
                ForEach(dataManager.powers, id: \.name) { power in
                    HStack {
                        Text(power.name)
                        if power.levels {
                            TextField("Points", value: Binding(
                                get: { selectedPowers[power.name] ?? 0.0 },
                                set: { selectedPowers[power.name] = $0 }
                            ), format: .number)
                        } else {
                            Button("Add") {
                                selectedPowers[power.name] = power.cost
                            }
                        }
                    }
                }
            }
            
            Section("Complex Forms") {
                ForEach(dataManager.complexForms, id: \.name) { form in
                    Button(action: {
                        if selectedComplexForms.contains(form.name) {
                            selectedComplexForms.removeAll { $0 == form.name }
                        } else {
                            selectedComplexForms.append(form.name)
                        }
                    }) {
                        Text(form.name)
                            .foregroundColor(selectedComplexForms.contains(form.name) ? .blue : .primary)
                    }
                }
            }
            
            Section("Tradition") {
                Picker("Tradition", selection: $selectedTradition) {
                    Text("None").tag(String?.none)
                    ForEach(dataManager.traditions, id: \.name) { tradition in
                        Text(tradition.name).tag(String?.some(tradition.name))
                    }
                }
            }
            
            Section("Mentor Spirit") {
                Picker("Mentor", selection: $selectedMentor) {
                    Text("None").tag(String?.none)
                    ForEach(dataManager.mentors, id: \.name) { mentor in
                        Text(mentor.name).tag(String?.some(mentor.name))
                    }
                }
            }
            
            Button("Next") {
                character.spells = selectedSpells
                character.powers = selectedPowers
                character.complexForms = selectedComplexForms
                character.tradition = selectedTradition
                character.mentor = selectedMentor
                onComplete()
            }
        }
        .navigationTitle("Select Magic/Resonance")
    }
}
