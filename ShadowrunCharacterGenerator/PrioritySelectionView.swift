//
//  PrioritySelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct PrioritySelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    @State private var prioritySelection: PrioritySelection?
    
    struct PrioritySelection {
        var metatype: String
        var attributes: String
        var skills: String
        var magic: String
        var resources: String
    }
    
    var body: some View {
        Form {
            Picker("Metatype Priority", selection: Binding(
                get: { prioritySelection?.metatype ?? "" },
                set: { newValue in
                    if prioritySelection == nil {
                        prioritySelection = PrioritySelection(metatype: newValue, attributes: "", skills: "", magic: "", resources: "")
                    } else {
                        prioritySelection?.metatype = newValue
                    }
                }
            )) {
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { Text($0) }
            }
            
            Picker("Attributes Priority", selection: Binding(
                get: { prioritySelection?.attributes ?? "" },
                set: { newValue in
                    prioritySelection?.attributes = newValue
                }
            )) {
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { Text($0) }
            }
            
            Picker("Skills Priority", selection: Binding(
                get: { prioritySelection?.skills ?? "" },
                set: { newValue in
                    prioritySelection?.skills = newValue
                }
            )) {
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { Text($0) }
            }
            
            Picker("Magic Priority", selection: Binding(
                get: { prioritySelection?.magic ?? "" },
                set: { newValue in
                    prioritySelection?.magic = newValue
                }
            )) {
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { Text($0) }
            }
            
            Picker("Resources Priority", selection: Binding(
                get: { prioritySelection?.resources ?? "" },
                set: { newValue in
                    prioritySelection?.resources = newValue
                }
            )) {
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { Text($0) }
            }
            
            Button("Next") {
                if let selection = prioritySelection {
                    // Store priority selections or initialize character data
                    character.attributes = ["Body": 1, "Agility": 1, "Reaction": 1, "Strength": 1, "Charisma": 1, "Intuition": 1, "Logic": 1, "Willpower": 1, "Edge": 1]
                    character.nuyen = dataManager.priorityData.resources[selection.resources] ?? 0
                    onComplete()
                }
            }
            .disabled(prioritySelection == nil)
        }
        .navigationTitle("Select Priorities")
    }
}
