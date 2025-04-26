//
//  MagicSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct MagicSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    let onPrevious: (() -> Void)?
    @State private var selectedSpells: [String] = []
    @State private var selectedPowers: [String: Double] = [:]
    @State private var selectedComplexForms: [String] = []
    @State private var selectedMentor: String?
    @State private var selectedTradition: String?
    @State private var errorMessage: String?
    @State private var magicPoints: Int = 0
    @State private var powerPoints: Double = 0.0

    private var isPrioritySet: Bool {
        character.priority != nil
    }

    init(character: Binding<Character>, onComplete: @escaping () -> Void, onPrevious: (() -> Void)? = nil) {
        self._character = character
        self.onComplete = onComplete
        self.onPrevious = onPrevious
    }

    var body: some View {
        Form {
            errorSection
            if errorMessage == nil && isPrioritySet {
                contentView
                // Navigation
                HStack {
                    if onPrevious != nil {
                        Button("Previous") {
                            onPrevious?()
                        }
                        .buttonStyle(.bordered)
                    }
                    Spacer()
                    Button("Next") {
                        character.spells = selectedSpells
                        character.powers = selectedPowers
                        character.complexForms = selectedComplexForms
                        character.tradition = selectedTradition
                        character.mentor = selectedMentor
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isNextButtonDisabled)
                }
                .padding()
            }
        }
        .navigationTitle("Select Magic/Resonance")
        .onAppear {
            initializeMagicSelection()
        }
    }

    private var errorSection: some View {
        Group {
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            if !isPrioritySet {
                Text("Error: Character priority not set. Please complete priority selection before proceeding.")
                    .foregroundColor(.red)
                    .padding()
            }
            let dataTypes = [
                ("priorities", "priorities.json"),
                ("spells", "spells.json"),
                ("powers", "powers.json"),
                ("complexforms", "complexforms.json"),
                ("traditions", "traditions.json"),
                ("mentors", "mentors.json")
            ]
            ForEach(dataTypes, id: \.0) { (key, file) in
                if let error = dataManager.errors[key] {
                    Text("Error: \(error). Please ensure \(file) is present and correctly formatted.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            if dataManager.spells.isEmpty && isMagicianOrMystic {
                Text("Error: No spells data available. Please ensure spells.json contains valid spell entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.powers.isEmpty && isAdeptOrMystic {
                Text("Error: No powers data available. Please ensure powers.json contains valid power entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.complexForms.isEmpty && isTechnomancer {
                Text("Error: No complex forms data available. Please ensure complexforms.json contains valid complex form entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.traditions.isEmpty && isMagicianOrMystic {
                Text("Error: No traditions data available. Please ensure traditions.json contains valid tradition entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.mentors.isEmpty && isMagicianOrMystic {
                Text("Error: No mentors data available. Please ensure mentors.json contains valid mentor entries.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    private var contentView: some View {
        Group {
            if isMagicianOrMystic && magicPoints > 0 {
                spellsSection
                traditionSection
                mentorSection
            }
            if isAdeptOrMystic && powerPoints > 0 {
                adeptPowersSection
            }
            if isTechnomancer && magicPoints > 0 {
                complexFormsSection
            }
        }
    }

    private var spellsSection: some View {
        Section("Spells (\(selectedSpells.count)/\(magicPoints))") {
            ForEach(dataManager.spells, id: \.id) { spell in
                Button(action: {
                    if selectedSpells.contains(spell.name) {
                        selectedSpells.removeAll { $0 == spell.name }
                    } else if selectedSpells.count < magicPoints {
                        selectedSpells.append(spell.name)
                    }
                }) {
                    Text(spell.name)
                        .foregroundColor(selectedSpells.contains(spell.name) ? .blue : .primary)
                }
                .disabled(selectedSpells.count >= magicPoints && !selectedSpells.contains(spell.name))
            }
        }
    }

    private var traditionSection: some View {
        Section("Tradition") {
            Picker("Tradition", selection: $selectedTradition) {
                Text("None").tag(String?.none)
                ForEach(dataManager.traditions, id: \.id) { tradition in
                    Text(tradition.name).tag(String?.some(tradition.name))
                }
            }
        }
    }

    private var mentorSection: some View {
        Section("Mentor Spirit") {
            Picker("Mentor", selection: $selectedMentor) {
                Text("None").tag(String?.none)
                ForEach(dataManager.mentors, id: \.id) { mentor in
                    Text(mentor.name).tag(String?.some(mentor.name))
                }
            }
        }
    }

    private var adeptPowersSection: some View {
        Section("Adept Powers (Remaining: \(powerPoints - selectedPowers.values.reduce(0, +), specifier: "%.1f"))") {
            ForEach(dataManager.powers, id: \.id) { power in
                HStack {
                    Text(power.name)
                    if power.levels == "Yes" {
                        TextField("Points", value: Binding(
                            get: { selectedPowers[power.name] ?? 0.0 },
                            set: { newValue in
                                let totalPoints = selectedPowers.values.reduce(0, +) - (selectedPowers[power.name] ?? 0) + newValue
                                if totalPoints <= powerPoints && newValue >= 0 {
                                    selectedPowers[power.name] = newValue
                                }
                            }
                        ), format: .number)
                    } else {
                        Button("Add") {
                            let points = Double(power.points) ?? 0.0
                            let totalPoints = selectedPowers.values.reduce(0, +) + points
                            if totalPoints <= powerPoints {
                                selectedPowers[power.name] = points
                            }
                        }
                        .disabled(selectedPowers.values.reduce(0, +) + (Double(power.points) ?? 0.0) > powerPoints)
                    }
                }
            }
        }
    }

    private var complexFormsSection: some View {
        Section("Complex Forms (\(selectedComplexForms.count)/\(magicPoints))") {
            ForEach(dataManager.complexForms, id: \.id) { form in
                Button(action: {
                    if selectedComplexForms.contains(form.name) {
                        selectedComplexForms.removeAll { $0 == form.name }
                    } else if selectedComplexForms.count < magicPoints {
                        selectedComplexForms.append(form.name)
                    }
                }) {
                    Text(form.name)
                        .foregroundColor(selectedComplexForms.contains(form.name) ? .blue : .primary)
                }
                .disabled(selectedComplexForms.count >= magicPoints && !selectedComplexForms.contains(form.name))
            }
        }
    }

    private var isMagicianOrMystic: Bool {
        guard let priority = character.priority else { return false }
        let magicType = priority.magic
        guard let magicPriority = dataManager.priorityData.magic[magicType] else { return false }
        return magicPriority.type.contains("Magician") || magicPriority.type.contains("Mystic Adept")
    }

    private var isAdeptOrMystic: Bool {
        guard let priority = character.priority else { return false }
        let magicType = priority.magic
        guard let magicPriority = dataManager.priorityData.magic[magicType] else { return false }
        return magicPriority.type.contains("Adept") || magicPriority.type.contains("Mystic Adept")
    }

    private var isTechnomancer: Bool {
        guard let priority = character.priority else { return false }
        let magicType = priority.magic
        guard let magicPriority = dataManager.priorityData.magic[magicType] else { return false }
        return magicPriority.type.contains("Technomancer")
    }

    private var isNextButtonDisabled: Bool {
        if !isPrioritySet {
            return true
        }
        if isMagicianOrMystic && magicPoints > 0 && selectedSpells.count < magicPoints {
            return true
        }
        if isTechnomancer && magicPoints > 0 && selectedComplexForms.count < magicPoints {
            return true
        }
        return false
    }

    private func initializeMagicSelection() {
        guard let priority = character.priority else {
            errorMessage = "Error: Character priority not set. Please complete priority selection before proceeding."
            return
        }
        let priorityLevel = priority.magic
        guard let magicPriority = dataManager.priorityData.magic[priorityLevel] else {
            errorMessage = "Error: Magic priority not selected or invalid. Please select a valid magic priority."
            return
        }
        magicPoints = magicPriority.points
        powerPoints = magicPriority.type.contains("Adept") ? Double(magicPriority.points) : 0.0
        selectedSpells = character.spells
        selectedPowers = character.powers
        selectedComplexForms = character.complexForms
        selectedTradition = character.tradition
        selectedMentor = character.mentor
    }
}

struct MagicSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MagicSelectionView(
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
                karma: 0,
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
            dm.priorityData = PriorityData(
                metatype: [:],
                attributes: [:],
                skills: [:],
                magic: [
                    "D-Adept": MagicPriority(type: "Adept", points: 2, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil),
                    "E-Mundane": MagicPriority(type: "Mundane", points: 0, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil)
                ],
                resources: [:]
            )
            dm.spells = [Spell(
                id: "1",
                name: "Fireball",
                page: "123",
                source: "Core",
                category: "Combat",
                damage: "P",
                descriptor: nil,
                duration: "I",
                dv: "F-1",
                range: "LOS",
                type: "Physical",
                bonus: nil,
                required: nil
            )]
            dm.powers = [Power(
                id: "1",
                name: "Improved Reflexes",
                points: "1.5",
                levels: "Yes",
                limit: nil,
                source: "Core",
                page: "123",
                action: "Auto"
            )]
            dm.complexForms = [ComplexForm(
                id: "1",
                name: "Resonance Spike",
                target: "Device",
                duration: "I",
                fv: "L-2",
                source: "Core",
                page: "123"
            )]
            dm.traditions = [Tradition(
                id: "1",
                name: "Hermetic",
                drain: ["Willpower": "Logic"],
                source: "Core",
                page: "123",
                spirits: nil
            )]
            dm.mentors = [Mentor(
                id: "1",
                name: "Dragon",
                advantage: "Magic",
                disadvantage: "Test",
                choices: nil,
                source: "Core",
                page: "123"
            )]
            dm.errors = [:]
            return dm
        }())
    }
}
