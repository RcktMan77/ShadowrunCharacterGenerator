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
    
    var body: some View {
        Form {
            Section("Metamagic") {
                ForEach(dataManager.metamagic, id: \.name) { metamagic in
                    Button(action: {
                        if character.karma >= metamagic.cost {
                            character.karma -= metamagic.cost
                            character.metamagic.append(metamagic.name)
                        }
                    }) {
                        Text("\(metamagic.name) (\(metamagic.cost) Karma)")
                    }
                }
            }
            
            Section("Echoes") {
                ForEach(dataManager.echoes, id: \.name) { echo in
                    Button(action: {
                        if character.karma >= echo.cost {
                            character.karma -= echo.cost
                            character.echoes.append(echo.name)
                        }
                    }) {
                        Text("\(echo.name) (\(echo.cost) Karma)")
                    }
                }
            }
            
            // Add sections for attribute/skill upgrades, qualities, etc.
        }
        .navigationTitle("Character Progression")
    }
}
