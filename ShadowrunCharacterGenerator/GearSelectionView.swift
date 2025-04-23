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
    
    var body: some View {
        List {
            ForEach(dataManager.gear, id: \.name) { item in
                HStack {
                    Text(item.name)
                    Text("\(item.cost) Nuyen")
                    Button("Buy") {
                        if character.nuyen >= item.cost {
                            character.nuyen -= item.cost
                            character.gear[item.name, default: 0] += 1
                        }
                    }
                }
            }
        }
    }
}
