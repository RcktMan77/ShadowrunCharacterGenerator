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
    let selectedMetatype: String // Selected metatype from MetatypeSelectionView
    let onComplete: () -> Void
    let onPrevious: (() -> Void)?
    
    @State private var prioritySelection: PrioritySelection?
    @State private var errorMessage: String?
    
    struct PrioritySelection {
        var metatype: String
        var attributes: String
        var skills: String
        var magic: String
        var resources: String
    }
    
    // Available priority levels
    private let priorityLevels = ["A", "B", "C", "D", "E"]
    
    // Compute used priorities to enforce uniqueness
    private var usedPriorities: Set<String> {
        guard let selection = prioritySelection else { return [] }
        return Set([selection.metatype, selection.attributes, selection.skills, selection.magic, selection.resources].filter { !$0.isEmpty })
    }
    
    var body: some View {
        VStack(spacing: 20) { // Increased vertical spacing
            Form {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.vertical, 5)
                }
                
                // Metatype Priority
                Picker("Metatype Priority", selection: Binding(
                    get: { prioritySelection?.metatype ?? "" },
                    set: { newValue in
                        updatePrioritySelection(metatype: newValue)
                        selectedMetatypePriority = newValue
                        validateMagicOptions()
                    }
                )) {
                    Text("Select").tag("")
                    ForEach(priorityLevels.filter { isMetatypePriorityValid($0) && (!usedPriorities.contains($0) || $0 == prioritySelection?.metatype) }, id: \.self) { priority in
                        Text(priorityLabel(for: priority, category: .metatype))
                            .tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 250, alignment: .center) // Fixed uniform width
                .clipped()
                .help(priorityTooltip(for: .metatype))
                .disabled(selectedMetatype.isEmpty)
                
                // Attributes Priority
                Picker("Attributes Priority", selection: Binding(
                    get: { prioritySelection?.attributes ?? "" },
                    set: { newValue in
                        updatePrioritySelection(attributes: newValue)
                    }
                )) {
                    Text("Select").tag("")
                    ForEach(priorityLevels.filter { !usedPriorities.contains($0) || $0 == prioritySelection?.attributes }, id: \.self) { priority in
                        Text(priorityLabel(for: priority, category: .attributes))
                            .tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 250, alignment: .center) // Fixed uniform width
                .clipped()
                .help(priorityTooltip(for: .attributes))
                
                // Skills Priority
                Picker("Skills Priority", selection: Binding(
                    get: { prioritySelection?.skills ?? "" },
                    set: { newValue in
                        updatePrioritySelection(skills: newValue)
                    }
                )) {
                    Text("Select").tag("")
                    ForEach(priorityLevels.filter { !usedPriorities.contains($0) || $0 == prioritySelection?.skills }, id: \.self) { priority in
                        Text(priorityLabel(for: priority, category: .skills))
                            .tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 250, alignment: .center) // Fixed uniform width
                .clipped()
                .help(priorityTooltip(for: .skills))
                
                // Magic Priority
                Picker("Magic Priority", selection: Binding(
                    get: { prioritySelection?.magic ?? "" },
                    set: { newValue in
                        updatePrioritySelection(magic: newValue)
                        validateMagicOptions()
                    }
                )) {
                    Text("Select").tag("")
                    ForEach(priorityLevels.filter {
                        (!usedPriorities.contains($0) || $0 == prioritySelection?.magic) &&
                        isMagicPriorityValid($0)
                    }, id: \.self) { priority in
                        Text(priorityLabel(for: priority, category: .magic))
                            .tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 250, alignment: .center) // Fixed uniform width
                .clipped()
                .disabled(selectedMetatype.isEmpty || prioritySelection?.metatype.isEmpty ?? true)
                .help(priorityTooltip(for: .magic))
                
                // Resources Priority
                Picker("Resources Priority", selection: Binding(
                    get: { prioritySelection?.resources ?? "" },
                    set: { newValue in
                        updatePrioritySelection(resources: newValue)
                    }
                )) {
                    Text("Select").tag("")
                    ForEach(priorityLevels.filter { !usedPriorities.contains($0) || $0 == prioritySelection?.resources }, id: \.self) { priority in
                        Text(priorityLabel(for: priority, category: .resources))
                            .tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 250, alignment: .center) // Fixed uniform width
                .clipped()
                .help(priorityTooltip(for: .resources))
                
                // Actions
                HStack {
                    Spacer()
                    if onPrevious != nil {
                        Button("Previous") {
                            onPrevious?()
                        }
                        .buttonStyle(.bordered)
                    }
                    Button("Reset") {
                        prioritySelection = nil
                        selectedMetatypePriority = ""
                        character.priority = nil
                        character.nuyen = 0
                        errorMessage = nil
                    }
                    .buttonStyle(.bordered)
                    Button("Next") {
                        if let selection = prioritySelection, arePrioritiesValid(selection: selection) {
                            character.priority = Character.PrioritySelection(
                                metatype: selection.metatype,
                                attributes: selection.attributes,
                                skills: selection.skills,
                                magic: selection.magic,
                                resources: selection.resources
                            )
                            character.nuyen = dataManager.priorityData.resources[selection.resources] ?? 0
                            onComplete()
                        } else {
                            errorMessage = "Please assign a unique priority (A–E) to each category."
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isSelectionComplete)
                    Spacer()
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: 600) // Constrain form width
        }
        .frame(maxWidth: .infinity, alignment: .center) // Center content
        .navigationTitle("Select Priorities")
        .onAppear {
            // Restore previous selections
            if let existingPriority = character.priority {
                prioritySelection = PrioritySelection(
                    metatype: existingPriority.metatype,
                    attributes: existingPriority.attributes,
                    skills: existingPriority.skills,
                    magic: existingPriority.magic,
                    resources: existingPriority.resources
                )
                selectedMetatypePriority = existingPriority.metatype
            }
            
            // Check data availability
            if dataManager.priorityData.metatype.isEmpty ||
               dataManager.priorityData.attributes.isEmpty ||
               dataManager.priorityData.skills.isEmpty ||
               dataManager.priorityData.magic.isEmpty ||
               dataManager.priorityData.resources.isEmpty {
                errorMessage = "Failed to load priority data. Please try again."
            } else if selectedMetatype.isEmpty {
                errorMessage = "Please select a metatype before choosing priorities."
            } else {
                print("Magic Priorities: \(dataManager.priorityData.magic)")
            }
        }
    }
    
    // Check if all priorities are assigned
    private var isSelectionComplete: Bool {
        guard let selection = prioritySelection else { return false }
        let isComplete = arePrioritiesValid(selection: selection)
        print("Selection Complete: \(isComplete), Priorities: \(String(describing: selection))")
        return isComplete
    }
    
    // Update priority selection with new values
    private func updatePrioritySelection(
        metatype: String? = nil,
        attributes: String? = nil,
        skills: String? = nil,
        magic: String? = nil,
        resources: String? = nil
    ) {
        if prioritySelection == nil {
            prioritySelection = PrioritySelection(metatype: "", attributes: "", skills: "", magic: "", resources: "")
        }
        if let metatype = metatype {
            prioritySelection?.metatype = metatype
        }
        if let attributes = attributes {
            prioritySelection?.attributes = attributes
        }
        if let skills = skills {
            prioritySelection?.skills = skills
        }
        if let magic = magic {
            prioritySelection?.magic = magic
        }
        if let resources = resources {
            prioritySelection?.resources = resources
        }
        errorMessage = nil
    }
    
    // Validate that priorities are unique and complete
    private func arePrioritiesValid(selection: PrioritySelection?) -> Bool {
        guard let selection = selection else { return false }
        let priorities = [
            selection.metatype,
            selection.attributes,
            selection.skills,
            selection.magic,
            selection.resources
        ]
        let isValid = priorities.allSatisfy { !$0.isEmpty } && Set(priorities).count == priorities.count
        print("Priorities Valid: \(isValid), Priorities: \(priorities)")
        return isValid
    }
    
    // Validate Metatype priority based on selected metatype
    private func isMetatypePriorityValid(_ priority: String) -> Bool {
        guard !selectedMetatype.isEmpty else { return true } // Allow all if no metatype selected
        guard let metatypeOptions = dataManager.priorityData.metatype[priority] else { return false }
        let metatypeNames = metatypeOptions.map { $0.name }
        return metatypeNames.contains(selectedMetatype)
    }
    
    // Get MagicPriority options for a priority level
    private func getMagicOptions(for priority: String) -> [MagicPriority] {
        return dataManager.priorityData.magic
            .filter { $0.key.hasPrefix("\(priority)-") }
            .map { $0.value }
            .sorted { $0.type < $1.type }
    }
    
    // Validate Magic priority based on Metatype
    private func isMagicPriorityValid(_ priority: String) -> Bool {
        guard !selectedMetatype.isEmpty, let prioritySelection = prioritySelection, !prioritySelection.metatype.isEmpty,
              let metatypeOptions = dataManager.priorityData.metatype[prioritySelection.metatype] else {
            print("Magic Validation: No metatype selected or priority not set for priority \(priority)")
            return true // Allow all if no metatype selected
        }
        let metatypeNames = metatypeOptions.map { $0.name }
        let magicOptions = getMagicOptions(for: priority)
        // SR5 Rule: Trolls cannot be Technomancers
        if metatypeNames.contains("Troll") && magicOptions.contains(where: { $0.type.contains("Technomancer") }) {
            print("Magic Validation: Troll cannot be Technomancer for priority \(priority)")
            return false
        }
        // SR5 Rule: Magic/Resonance rating cannot exceed special attribute points
        let maxSpecialPoints = metatypeOptions.map { $0.specialAttributePoints }.max() ?? 0
        let maxMagicRating = magicOptions.map { $0.points }.max() ?? 0
        if maxMagicRating > maxSpecialPoints {
            print("Magic Validation: Magic rating \(maxMagicRating) exceeds special points \(maxSpecialPoints) for priority \(priority)")
            return false
        }
        // Optional: Restrict Technomancer to Human, Elf, Dwarf, Ork
        if magicOptions.contains(where: { $0.type.contains("Technomancer") }) {
            let isValid = metatypeNames.contains { ["Human", "Elf", "Dwarf", "Ork"].contains($0) }
            print("Magic Validation: Technomancer restricted to Human, Elf, Dwarf, Ork: \(isValid)")
            return isValid
        }
        return true
    }
    
    // Validate and reset Magic if incompatible
    private func validateMagicOptions() {
        guard let magicPriority = prioritySelection?.magic, !magicPriority.isEmpty else { return }
        if !isMagicPriorityValid(magicPriority) {
            prioritySelection?.magic = ""
            errorMessage = "Selected Magic priority is incompatible with Metatype. Please choose a different Magic priority."
            print("Magic Reset: Incompatible magic priority \(magicPriority)")
        }
    }
    
    // Generate concise labels for pull-down menus
    private func priorityLabel(for forPriority: String, category: PriorityCategory) -> String {
        switch category {
        case .metatype:
            if let options = dataManager.priorityData.metatype[forPriority], !options.isEmpty,
               !selectedMetatype.isEmpty,
               let option = options.first(where: { $0.name == selectedMetatype }) {
                let points = option.specialAttributePoints
                let specialPointsDesc = selectedMetatype == "Troll" ?
                    "for Edge or Magic" :
                    "for Edge, Magic, or Resonance"
                return "\(forPriority): \(selectedMetatype) (\(points) Special Pts \(specialPointsDesc))"
            } else if let options = dataManager.priorityData.metatype[forPriority], !options.isEmpty {
                let points = options.first?.specialAttributePoints ?? 0
                return "\(forPriority): Metatypes (\(points) Special Pts)"
            }
        case .attributes:
            if let points = dataManager.priorityData.attributes[forPriority] {
                return "\(forPriority): \(points) Attribute Pts"
            }
        case .skills:
            if let skillPriority = dataManager.priorityData.skills[forPriority] {
                return "\(forPriority): \(skillPriority.skillPoints) Skill Pts"
            }
        case .magic:
            let magicOptions = getMagicOptions(for: forPriority)
            if !magicOptions.isEmpty {
                let types = magicOptions.prefix(3).map { $0.type }.joined(separator: ", ")
                let suffix = magicOptions.count > 3 ? ", ..." : ""
                return "\(forPriority): \(types)\(suffix)"
            }
        case .resources:
            if let nuyen = dataManager.priorityData.resources[forPriority] {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return "\(forPriority): \(formatter.string(from: NSNumber(value: nuyen)) ?? String(nuyen))¥"
            }
        }
        return forPriority
    }
    
    // Generate detailed tooltips for priority categories
    private func priorityTooltip(for category: PriorityCategory) -> String {
        switch category {
        case .metatype:
            let sampleMetatypes = dataManager.priorityData.metatype.map { priority, options in
                let names = options.prefix(3).map { $0.name }.joined(separator: ", ")
                let points = options.first?.specialAttributePoints ?? 0
                return "\(priority): \(names)\(options.count > 3 ? ", ..." : "") (\(points) Special Points)"
            }.joined(separator: "; ")
            let specialPointsDesc = selectedMetatype == "Troll" ?
                "Special Points can be spent on Edge (luck) or Magic (if Magician/Adept)." :
                "Special Points can be spent on Edge (luck), Magic (if Magician/Adept), or Resonance (if Technomancer)."
            return "Choose the priority for your character's race (\(selectedMetatype.isEmpty ? "none selected" : selectedMetatype)). \(specialPointsDesc) Options: \(sampleMetatypes)"
        case .attributes:
            return "Allocate points to physical and mental attributes (e.g., Body, Agility, Logic). Higher priorities provide more points."
        case .skills:
            return "Determine points for active skills (e.g., Stealth, Firearms) and skill groups. Higher priorities offer more skill points and group points."
        case .magic:
            return "Select magical or resonance abilities (e.g., Magician, Adept, Technomancer). Higher priorities provide more Magic/Resonance and spells/complex forms. Options may be restricted by metatype."
        case .resources:
            return "Set starting Nuyen for gear, cyberware, and lifestyle. Higher priorities provide more Nuyen."
        }
    }
    
    enum PriorityCategory {
        case metatype, attributes, skills, magic, resources
    }
}

// Preview
struct PrioritySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PrioritySelectionView(
            character: .constant(Character(
                name: "",
                metatype: "Troll",
                priority: nil,
                attributes: [:],
                skills: [:],
                specializations: [:],
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
            selectedMetatypePriority: .constant(""),
            selectedMetatype: "Troll",
            onComplete: {},
            onPrevious: nil
        )
        .environmentObject({
            let dm = DataManager()
            dm.priorityData = PriorityData(
                metatype: [
                    "A": [MetatypeOption(name: "Human", specialAttributePoints: 9, karma: 0), MetatypeOption(name: "Elf", specialAttributePoints: 8, karma: 0)],
                    "B": [MetatypeOption(name: "Dwarf", specialAttributePoints: 7, karma: 0)],
                    "C": [MetatypeOption(name: "Ork", specialAttributePoints: 7, karma: 0)],
                    "D": [MetatypeOption(name: "Troll", specialAttributePoints: 5, karma: 0)],
                    "E": [MetatypeOption(name: "Human", specialAttributePoints: 1, karma: 0)]
                ],
                attributes: ["A": 24, "B": 20, "C": 16, "D": 14, "E": 12],
                skills: [
                    "A": SkillPriority(skillPoints: 46, skillGroupPoints: 10),
                    "B": SkillPriority(skillPoints: 36, skillGroupPoints: 5),
                    "C": SkillPriority(skillPoints: 28, skillGroupPoints: 2),
                    "D": SkillPriority(skillPoints: 22, skillGroupPoints: 0),
                    "E": SkillPriority(skillPoints: 18, skillGroupPoints: 0)
                ],
                magic: [
                    "A-Magician": MagicPriority(type: "Magician", points: 6, spells: 10, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil),
                    "A-Adept": MagicPriority(type: "Adept", points: 6, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil),
                    "A-Technomancer": MagicPriority(type: "Technomancer", points: 6, spells: nil, complexForms: 5, skillQty: nil, skillVal: nil, skillType: nil),
                    "B-Mystic Adept": MagicPriority(type: "Mystic Adept", points: 4, spells: 7, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil),
                    "C-Aspected Magician": MagicPriority(type: "Aspected Magician", points: 3, spells: 5, complexForms: nil, skillQty: 2, skillVal: 4, skillType: "Magical"),
                    "D-Adept": MagicPriority(type: "Adept", points: 2, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil),
                    "E-Mundane": MagicPriority(type: "Mundane", points: 0, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil)
                ],
                resources: ["A": 450000, "B": 275000, "C": 140000, "D": 50000, "E": 6000]
            )
            return dm
        }())
    }
}
