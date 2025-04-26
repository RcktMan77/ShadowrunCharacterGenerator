//
//  SkillsAllocationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct SkillsAllocationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    let onPrevious: (() -> Void)?
    @State private var errorMessage: String?
    @State private var selectedCategory: String = ""
    @State private var searchText: String = ""
    @State private var skillGroupAllocations: [String: Int] = [:] // Tracks skill group points
    
    // Derive skill categories from skills
    private var skillCategories: [String] {
        Array(Set(dataManager.skills.map { $0.category })).sorted()
    }
    
    // Derive skill groups from skills
    private var availableSkillGroups: [String] {
        Array(Set(dataManager.skills.compactMap { $0.skillgroup }).sorted())
    }
    
    private var filteredSkills: [Skill] {
        dataManager.skills.filter { skill in
            (selectedCategory.isEmpty || skill.category == selectedCategory) &&
            (searchText.isEmpty || skill.name.lowercased().contains(searchText.lowercased()))
        }
    }
    
    private var skillPointsSpent: Int {
        character.skills.values.reduce(0, +)
    }
    
    private var skillPointsRemaining: Int {
        let totalPoints = dataManager.priorityData.skills[character.priority?.skills ?? "E"]?.skillPoints ?? 18
        return max(0, totalPoints - skillPointsSpent)
    }
    
    private var groupPointsSpent: Int {
        skillGroupAllocations.values.reduce(0, +)
    }
    
    private var groupPointsRemaining: Int {
        let totalPoints = dataManager.priorityData.skills[character.priority?.skills ?? "E"]?.skillGroupPoints ?? 0
        return max(0, totalPoints - groupPointsSpent)
    }
    
    private var karmaSpent: Int {
        var karma = 0
        for (skillName, points) in character.skills {
            if let skill = dataManager.skills.first(where: { $0.name == skillName }) {
                let minPoints = skill.default == "Yes" ? 0 : 1 // SR5: Defaultable skills have min 0, others 1
                if points > minPoints {
                    karma += (points - minPoints) * 2 // 2 karma per point (p. 98)
                }
            }
        }
        karma += character.specializations.count * 7 // 7 karma per specialization (p. 98)
        return karma
    }
    
    private var skillGroups: [[String]] {
        var grid: [[String]] = []
        for i in stride(from: 0, to: availableSkillGroups.count, by: 3) {
            var row: [String] = []
            for j in i..<min(i + 3, availableSkillGroups.count) {
                row.append(availableSkillGroups[j])
            }
            grid.append(row)
        }
        return grid
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Form {
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.vertical, 8)
                    }
                    
                    Section(header: Text("Category Filter")) {
                        Picker("Skill Category", selection: $selectedCategory) {
                            Text("All").tag("")
                            ForEach(skillCategories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 200, alignment: .leading)
                        .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 8)
                    
                    Section(header: Text("Search Skills")) {
                        TextField("Search Skills", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    Section(header: Text("Individual Skills")) {
                        if filteredSkills.isEmpty {
                            Text("No skills match the current filter")
                                .foregroundColor(.secondary)
                        } else {
                            List(filteredSkills, id: \.id) { skill in
                                skillRow(skill: skill)
                                    .padding(.vertical, 4)
                            }
                            .frame(minHeight: 300, maxHeight: 300)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Section(header: Text("Skill Groups")) {
                        if availableSkillGroups.isEmpty {
                            Text("No skill groups available")
                                .foregroundColor(.secondary)
                        } else {
                            VStack(spacing: 4) {
                                ForEach(skillGroups, id: \.self) { row in
                                    HStack(spacing: 10) {
                                        ForEach(row, id: \.self) { group in
                                            skillGroupColumn(group: group)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Section {
                        HStack {
                            Text("Skill Points Spent: \(skillPointsSpent)")
                            Spacer()
                            Text("Skill Points Remaining: \(skillPointsRemaining)")
                        }
                        HStack {
                            Text("Skill Group Points Spent: \(groupPointsSpent)")
                            Spacer()
                            Text("Skill Group Points Remaining: \(groupPointsRemaining)")
                        }
                        HStack {
                            Text("Karma Spent: \(karmaSpent)")
                            Spacer()
                            Text("Karma Remaining: \(character.karma)")
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Section {
                        HStack {
                            Spacer()
                            if onPrevious != nil {
                                Button("Previous") {
                                    onPrevious?()
                                }
                                .buttonStyle(.bordered)
                            }
                            Button("Reset") {
                                resetSkills()
                            }
                            .buttonStyle(.bordered)
                            Button("Next") {
                                onComplete()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(skillPointsSpent == 0 && groupPointsSpent == 0)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: 600)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Allocate Skills")
        .onAppear {
            print("SkillsAllocationView onAppear: skills=\(dataManager.skills.count), skillGroups=\(availableSkillGroups.count), categories=\(skillCategories), priority=\(String(describing: character.priority?.skills))")
            if character.priority?.skills == nil {
                errorMessage = "Please select a skills priority before allocating points."
            } else if dataManager.skills.isEmpty {
                errorMessage = "No skill data available."
            } else if skillCategories.isEmpty {
                errorMessage = "No skill categories available."
            } else {
                errorMessage = nil
            }
        }
    }
    
    private func skillGroupColumn(group: String) -> some View {
        VStack {
            Text(group)
                .font(.headline)
                .padding(.bottom, 4)
            Text("\(skillGroupAllocations[group] ?? 0)")
                .font(.body)
            Button("+") {
                if (skillGroupAllocations[group] ?? 0) < 6 {
                    skillGroupAllocations[group] = (skillGroupAllocations[group] ?? 0) + 1
                }
            }
            .font(.caption)
            .buttonStyle(.plain)
            .disabled((skillGroupAllocations[group] ?? 0) >= 6 || groupPointsRemaining <= 0)
            Button("−") {
                if let currentValue = skillGroupAllocations[group], currentValue > 0 {
                    skillGroupAllocations[group] = currentValue - 1
                }
            }
            .font(.caption)
            .buttonStyle(.plain)
            .disabled(skillGroupAllocations[group] == nil || skillGroupAllocations[group] == 0)
        }
    }
    
    private func skillRow(skill: Skill) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(skill.name)
                if let specialization = character.specializations[skill.name] {
                    Text("Spec: \(specialization)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(character.skills[skill.name] ?? (skill.default == "Yes" ? 0 : 1))")
            Button("−") {
                let minPoints = skill.default == "Yes" ? 0 : 1
                if let currentValue = character.skills[skill.name], currentValue > minPoints {
                    character.skills[skill.name] = currentValue - 1
                }
            }
            .disabled(character.skills[skill.name] == nil || character.skills[skill.name]! <= (skill.default == "Yes" ? 0 : 1))
            Button("+") {
                if (character.skills[skill.name] ?? (skill.default == "Yes" ? 0 : 1)) < 6 {
                    character.skills[skill.name] = (character.skills[skill.name] ?? (skill.default == "Yes" ? 0 : 1)) + 1
                }
            }
            .disabled((character.skills[skill.name] ?? (skill.default == "Yes" ? 0 : 1)) >= 6 || skillPointsRemaining <= 0)
            Button("+K") {
                if (character.skills[skill.name] ?? (skill.default == "Yes" ? 0 : 1)) < 6, character.karma >= 2 {
                    character.skills[skill.name] = (character.skills[skill.name] ?? (skill.default == "Yes" ? 0 : 1)) + 1
                    character.karma -= 2
                }
            }
            .disabled((character.skills[skill.name] ?? (skill.default == "Yes" ? 0 : 1)) >= 6 || character.karma < 2)
            Button("Spec") {
                if character.specializations[skill.name] == nil, character.karma >= 7, let specs = skill.specs, !specs.isEmpty {
                    character.specializations[skill.name] = specs[0] // Use first specialization; enhance later
                    character.karma -= 7
                }
            }
            .disabled(character.specializations[skill.name] != nil || character.karma < 7 || skill.specs == nil || skill.specs!.isEmpty)
        }
    }
    
    private func resetSkills() {
        character.skills = [:]
        skillGroupAllocations = [:]
        character.specializations = [:]
        let karmaRefund = karmaSpent
        character.karma += karmaRefund
        searchText = ""
        selectedCategory = ""
        errorMessage = nil
        print("Skills reset: skills=\(character.skills), skillGroupAllocations=\(skillGroupAllocations), specializations=\(character.specializations), karmaRefund=\(karmaRefund), karma=\(character.karma)")
    }
}

struct SkillsAllocationView_Previews: PreviewProvider {
    static var previews: some View {
        SkillsAllocationView(
            character: .constant(Character(
                name: "",
                metatype: "Human",
                priority: Character.PrioritySelection(metatype: "E", attributes: "B", skills: "A", magic: "E", resources: "C"),
                attributes: [:],
                skills: ["Firearms": 3],
                specializations: ["Firearms": "Pistols"],
                karma: 25,
                nuyen: 0,
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
            )),
            onComplete: {},
            onPrevious: {}
        )
        .environmentObject({
            let dm = DataManager()
            dm.skills = [
                Skill(
                    id: "1",
                    name: "Firearms",
                    attribute: "Agility",
                    category: "Combat",
                    default: "Yes",
                    skillgroup: "Firearms Group",
                    specs: ["Pistols", "Rifles"],
                    source: "Core",
                    page: "130"
                ),
                Skill(
                    id: "2",
                    name: "Stealth",
                    attribute: "Agility",
                    category: "Physical",
                    default: "Yes",
                    skillgroup: "Stealth Group",
                    specs: ["Sneaking", "Palming"],
                    source: "Core",
                    page: "132"
                ),
                Skill(
                    id: "3",
                    name: "Negotiation",
                    attribute: "Charisma",
                    category: "Social",
                    default: "No",
                    skillgroup: nil,
                    specs: ["Bargaining", "Diplomacy"],
                    source: "Core",
                    page: "135"
                )
            ]
            dm.priorityData = PriorityData(
                metatype: ["E": [MetatypeOption(name: "Human", specialAttributePoints: 1, karma: 0)]],
                attributes: ["B": 20],
                skills: ["A": SkillPriority(skillPoints: 46, skillGroupPoints: 10)],
                magic: ["E-Mundane": MagicPriority(type: "Mundane", points: 0, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil)],
                resources: ["C": 140000]
            )
            return dm
        }())
    }
}
