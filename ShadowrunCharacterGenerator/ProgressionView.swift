//
//  ProgressionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct ProgressionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @State private var errorMessage: String?

    var body: some View {
        Form {
            if let metamagicError = dataManager.errors["metamagic"] {
                Text("Error: \(metamagicError). Please ensure metamagic.json is present and correctly formatted.")
                    .foregroundColor(.red)
            } else if dataManager.metamagics.isEmpty {
                Text("Error: No metamagic data available. Please ensure metamagic.json contains valid metamagic entries.")
                    .foregroundColor(.red)
            } else {
                Section("Metamagic") {
                    ForEach(dataManager.metamagics, id: \.id) { metamagic in
                        Button(action: {
                            // Placeholder cost; adjust if cost field is added to Metamagic struct
                            let cost = 10
                            if character.karma >= cost {
                                character.karma -= cost
                                character.metamagic.append(metamagic.name)
                            } else {
                                errorMessage = "Error: Insufficient karma (\(character.karma)) to purchase \(metamagic.name) (\(cost) Karma). Please increase karma."
                            }
                        }) {
                            Text("\(metamagic.name) (\(10) Karma)") // Update with actual cost if added to Metamagic
                        }
                    }
                }
            }

            if let echoesError = dataManager.errors["echoes"] {
                Text("Error: \(echoesError). Please ensure echoes.json is present and correctly formatted.")
                    .foregroundColor(.red)
            } else if dataManager.echoes.isEmpty {
                Text("Error: No echoes data available. Please ensure echoes.json contains valid echo entries.")
                    .foregroundColor(.red)
            } else {
                Section("Echoes") {
                    ForEach(dataManager.echoes, id: \.id) { echo in
                        Button(action: {
                            // Placeholder cost; adjust if cost field is added to Echo struct
                            let cost = 15
                            if character.karma >= cost {
                                character.karma -= cost
                                character.echoes.append(echo.name)
                            } else {
                                errorMessage = "Error: Insufficient karma (\(character.karma)) to purchase \(echo.name) (\(cost) Karma). Please increase karma."
                            }
                        }) {
                            Text("\(echo.name) (\(15) Karma)") // Update with actual cost if added to Echo struct
                        }
                    }
                }
            }
        }
        .navigationTitle("Character Progression")
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

struct ProgressionView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressionView(
            character: .constant(Character(
                name: "Test",
                metatype: "Human",
                priority: Character.PrioritySelection(
                    metatype: "A",
                    attributes: "B",
                    skills: "C",
                    magic: "D",
                    resources: "E"
                ),
                attributes: [:],
                skills: [:],
                specializations: [:],
                karma: 25,
                nuyen: 6000,
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
            ))
        )
        .environmentObject({
            let dm = DataManager()
            // Set Published properties directly
            dm.metamagics = [
                Metamagic(id: "1", name: "Centering", adept: nil, magician: "yes", source: "Core", page: "320"),
                Metamagic(id: "2", name: "Quickening", adept: nil, magician: "yes", source: "Core", page: "320")
            ]
            dm.echoes = [
                Echo(id: "1", name: "Overclocking", source: "Core", page: "258", bonus: nil, limit: nil),
                Echo(id: "2", name: "Mind Over Machine", source: "Core", page: "258", bonus: nil, limit: nil)
            ]
            dm.errors = [:]
            return dm
        }())
    }
}
