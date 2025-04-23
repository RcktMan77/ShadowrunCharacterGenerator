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
    
    var body: some View {
        List {
            ForEach(dataManager.martialArts, id: \.name) { martialArt in
                Button(action: {
                    if character.karma >= martialArt.cost {
                        character.karma -= martialArt.cost
                        character.martialArts.append(martialArt.name)
                    }
                }) {
                    Text("\(martialArt.name) (\(martialArt.cost) Karma)")
                }
            }
        }
        .navigationTitle("Martial Arts")
    }
}
