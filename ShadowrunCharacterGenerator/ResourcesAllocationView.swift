//
//  ResourcesAllocationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct ResourcesAllocationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    
    var body: some View {
        Form {
            Text("Nuyen Remaining: \(character.nuyen)")
            
            Section("Gear") {
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
            
            Section("Armor") {
                ForEach(dataManager.armor, id: \.name) { item in
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
            
            Section("Weapons") {
                ForEach(dataManager.weapons, id: \.name) { item in
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
            
            // Add similar sections for cyberware, bioware, vehicles, programs, licenses, lifestyles
            
            Button("Next") {
                onComplete()
            }
        }
        .navigationTitle("Allocate Resources")
    }
}
