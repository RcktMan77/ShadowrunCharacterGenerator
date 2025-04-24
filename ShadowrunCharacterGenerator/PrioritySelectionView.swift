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
    @Binding var selectedMetatypePriority: String
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
            // Metatype Priority
            Picker("Metatype Priority", selection: Binding(
                get: { prioritySelection?.metatype ?? "" },
                set: { newValue in
                    if prioritySelection == nil {
                        prioritySelection = PrioritySelection(metatype: newValue, attributes: "", skills: "", magic: "", resources: "")
                    } else {
                        prioritySelection?.metatype = newValue
                    }
                    selectedMetatypePriority = newValue
                }
            )) {
                Text("Select priority").tag("")
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { priority in
                    Text(priorityDescription(for: priority, category: .metatype))
                        .tag(priority)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Attributes Priority
            Picker("Attributes Priority", selection: Binding(
                get: { prioritySelection?.attributes ?? "" },
                set: { newValue in
                    prioritySelection?.attributes = newValue
                }
            )) {
                Text("Select priority").tag("")
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { priority in
                    Text(priorityDescription(for: priority, category: .attributes))
                        .tag(priority)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Skills Priority
            Picker("Skills Priority", selection: Binding(
                get: { prioritySelection?.skills ?? "" },
                set: { newValue in
                    prioritySelection?.skills = newValue
                }
            )) {
                Text("Select priority").tag("")
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { priority in
                    Text(priorityDescription(for: priority, category: .skills))
                        .tag(priority)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Magic Priority
            Picker("Magic Priority", selection: Binding(
                get: { prioritySelection?.magic ?? "" },
                set: { newValue in
                    prioritySelection?.magic = newValue
                }
            )) {
                Text("Select priority").tag("")
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { priority in
                    Text(priorityDescription(for: priority, category: .magic))
                        .tag(priority)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Resources Priority
            Picker("Resources Priority", selection: Binding(
                get: { prioritySelection?.resources ?? "" },
                set: { newValue in
                    prioritySelection?.resources = newValue
                }
            )) {
                Text("Select priority").tag("")
                ForEach(["A", "B", "C", "D", "E"], id: \.self) { priority in
                    Text(priorityDescription(for: priority, category: .resources))
                        .tag(priority)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Button("Next") {
                if let selection = prioritySelection, arePrioritiesValid(selection: selection) {
                    character.attributes = ["Body": 1, "Agility": 1, "Reaction": 1, "Strength": 1, "Charisma": 1, "Intuition": 1, "Logic": 1, "Willpower": 1, "Edge": 1]
                    character.nuyen = dataManager.priorityData.resources[selection.resources] ?? 0
                    onComplete()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(prioritySelection == nil || !arePrioritiesValid(selection: prioritySelection))
        }
        .navigationTitle("Select Priorities")
    }
    
    // Validate that priorities are unique
    private func arePrioritiesValid(selection: PrioritySelection?) -> Bool {
        guard let selection = selection else { return false }
        let priorities = [
            selection.metatype,
            selection.attributes,
            selection.skills,
            selection.magic,
            selection.resources
        ]
        return priorities.allSatisfy { !$0.isEmpty } && Set(priorities).count == priorities.count
    }
    
    // Generate descriptive text for each priority
    private func priorityDescription(for priority: String, category: PriorityCategory) -> String {
        switch category {
        case .metatype:
            if let options = dataManager.priorityData.metatype[priority] {
                let names = options.map { "\($0.name) (\($0.specialAttributePoints))" }.joined(separator: ", ")
                return "\(priority): \(names.isEmpty ? "None" : names)"
            }
        case .attributes:
            if let points = dataManager.priorityData.attributes[priority] {
                return "\(priority): \(points) Attribute Points"
            }
        case .skills:
            if let skillPriority = dataManager.priorityData.skills[priority] {
                return "\(priority): \(skillPriority.skillPoints) Skill Points, \(skillPriority.skillGroupPoints) Skill Group Points"
            }
        case .magic:
            if let magicPriority = dataManager.priorityData.magic[priority] {
                return "\(priority): \(magicPriority.type) (\(magicPriority.points) Points)"
            }
        case .resources:
            if let nuyen = dataManager.priorityData.resources[priority] {
                return "\(priority): \(nuyen) Nuyen"
            }
        }
        return priority
    }
    
    enum PriorityCategory {
        case metatype, attributes, skills, magic, resources
    }
}
