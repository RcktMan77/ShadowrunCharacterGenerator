//
//  MartialArtsView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct MartialArtsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @State private var errorMessage: String?

    // Default karma cost for learning a martial art (update if cost is added to martialarts.json)
    private let defaultMartialArtCost = 7

    var body: some View {
        VStack {
            contentView
        }
        .navigationTitle("Martial Arts")
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

    private var contentView: some View {
        if let error = dataManager.errors["martialarts"] {
            return AnyView(
                Text("Error: \(error). Please ensure martialarts.json is present and correctly formatted.")
                    .foregroundColor(.red)
            )
        } else if dataManager.martialArts.isEmpty {
            return AnyView(
                Text("Error: No martial arts data available. Please ensure martialarts.json contains valid martial arts entries.")
                    .foregroundColor(.red)
            )
        } else {
            return AnyView(
                List {
                    ForEach(dataManager.martialArts, id: \.id) { martialArt in
                        martialArtButton(for: martialArt)
                    }
                }
            )
        }
    }

    private func martialArtButton(for martialArt: MartialArt) -> some View {
        Button(action: {
            let cost = defaultMartialArtCost // Replace with martialArt.cost if added to MartialArt struct
            if character.karma >= cost {
                character.karma -= cost
                character.martialArts.append(martialArt.name)
            } else {
                errorMessage = "Error: Insufficient karma (\(character.karma)) to purchase \(martialArt.name) (\(cost) Karma). Please increase karma."
            }
        }) {
            Text("\(martialArt.name) (\(defaultMartialArtCost) Karma)")
        }
    }
}
