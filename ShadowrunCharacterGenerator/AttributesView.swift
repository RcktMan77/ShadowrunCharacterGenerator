//
//  AttributesView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct AttributesView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @State private var errorMessage: String?
    @State private var attributePointsRemaining: Int = 0
    @State private var maxAttributeError: String?

    private var isPrioritySet: Bool {
        character.priority != nil
    }

    private var isAttributesPriorityValid: Bool {
        guard let priority = character.priority else { return false }
        return dataManager.priorityData.attributes[priority.attributes] != nil
    }

    private var isMetatypeSet: Bool {
        !character.metatype.isEmpty
    }

    private var isMetatypeValid: Bool {
        dataManager.metatypes.contains { $0.name == character.metatype }
    }

    private var isLowKarma: Bool {
        character.karma <= 10 && character.karma >= 0
    }

    private var isNegativeKarma: Bool {
        character.karma < 0
    }

    private func attributeRange(for attribute: String) -> ClosedRange<Int> {
        guard let metatype = dataManager.metatypes.first(where: { $0.name == character.metatype }) else {
            return 1...6 // Fallback range
        }

        switch attribute {
        case "Body":
            return (Int(metatype.bodmin) ?? 1)...(Int(metatype.bodmax) ?? 6)
        case "Agility":
            return (Int(metatype.agimin) ?? 1)...(Int(metatype.agimax) ?? 6)
        case "Reaction":
            return (Int(metatype.reamin) ?? 1)...(Int(metatype.reamax) ?? 6)
        case "Strength":
            return (Int(metatype.strmin) ?? 1)...(Int(metatype.strmax) ?? 6)
        case "Charisma":
            return (Int(metatype.chamin) ?? 1)...(Int(metatype.chamax) ?? 6)
        case "Intuition":
            return (Int(metatype.intmin) ?? 1)...(Int(metatype.intmax) ?? 6)
        case "Logic":
            return (Int(metatype.logmin) ?? 1)...(Int(metatype.logmax) ?? 6)
        case "Willpower":
            return (Int(metatype.wilmin) ?? 1)...(Int(metatype.wilmax) ?? 6)
        case "Edge":
            return (Int(metatype.edgmin) ?? 1)...(Int(metatype.edgmax) ?? 7)
        default:
            return 1...6
        }
    }

    private func canUpgradeAttribute(_ attribute: String, to newValue: Int) -> Bool {
        let range = attributeRange(for: attribute)
        if !range.contains(newValue) || attributePointsRemaining < 1 {
            return false
        }

        // Check if another attribute is already at its maximum
        let attributes = ["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"]
        let currentValues = attributes.map { attr in
            (attr, character.attributes[attr] ?? attributeRange(for: attr).lowerBound)
        }
        let maxedAttributes = currentValues.filter { (attr, value) in
            value == attributeRange(for: attr).upperBound && attr != attribute
        }

        if newValue == range.upperBound && !maxedAttributes.isEmpty {
            maxAttributeError = "Error: Only one attribute can be at its racial maximum. Please downgrade another attribute."
            return false
        }

        maxAttributeError = nil
        return true
    }

    var body: some View {
        Form {
            errorSection
            if errorMessage == nil && isPrioritySet && isAttributesPriorityValid && isMetatypeSet && isMetatypeValid && !isNegativeKarma {
                attributesSection
                pointsSection
            }
        }
        .navigationTitle("Allocate Attributes")
        .onAppear {
            initializeAttributes()
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
            if isPrioritySet && !isAttributesPriorityValid {
                Text("Error: Invalid attributes priority selected. Please select a valid attributes priority.")
                    .foregroundColor(.red)
                    .padding()
            }
            if !isMetatypeSet {
                Text("Error: Character metatype not set. Please select a valid metatype.")
                    .foregroundColor(.red)
                    .padding()
            }
            if isMetatypeSet && !isMetatypeValid {
                Text("Error: Invalid metatype selected. Please select a valid metatype.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.errors["metatypes"] != nil {
                Text("Error: Failed to load metatype data. Please ensure metatypes.json is present and correctly formatted.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.errors["priorities"] != nil {
                Text("Error: Failed to load priority data. Please ensure priorities.json is present and correctly formatted.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.metatypes.isEmpty {
                Text("Error: No metatype data available. Please ensure metatypes.json contains valid metatype entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.priorityData.attributes.isEmpty {
                Text("Error: No attributes priority data available. Please ensure priorities.json contains valid attributes priority entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if isNegativeKarma {
                Text("Error: Karma cannot be negative. Please ensure sufficient karma for attribute purchases.")
                    .foregroundColor(.red)
                    .padding()
            }
            if let maxError = maxAttributeError {
                Text(maxError)
                    .foregroundColor(.red)
                    .padding()
            }
            if isLowKarma {
                Text("Warning: Only \(character.karma) karma remaining! Consider prioritizing essential attributes.")
                    .foregroundColor(.orange)
                    .padding()
            }
        }
    }

    private var attributesSection: some View {
        Section(header: Text(NSLocalizedString("Attributes", comment: "Section header"))) {
            ForEach(["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"], id: \.self) { attr in
                HStack {
                    Text(NSLocalizedString(attr, comment: "Attribute name"))
                    Spacer()
                    Text("Value: \(character.attributes[attr] ?? attributeRange(for: attr).lowerBound)")
                    Button("Upgrade") {
                        let current = character.attributes[attr] ?? attributeRange(for: attr).lowerBound
                        let newValue = current + 1
                        if canUpgradeAttribute(attr, to: newValue) {
                            attributePointsRemaining -= 1
                            character.attributes[attr] = newValue
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canUpgradeAttribute(attr, to: (character.attributes[attr] ?? attributeRange(for: attr).lowerBound) + 1))
                    Button("Downgrade") {
                        let current = character.attributes[attr] ?? attributeRange(for: attr).lowerBound
                        let newValue = current - 1
                        let range = attributeRange(for: attr)
                        if range.contains(newValue) {
                            attributePointsRemaining += 1
                            character.attributes[attr] = newValue
                            maxAttributeError = nil // Clear max error on downgrade
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(!attributeRange(for: attr).contains((character.attributes[attr] ?? attributeRange(for: attr).lowerBound) - 1))
                }
            }
        }
    }

    private var pointsSection: some View {
        Section {
            Text("Attribute Points Remaining: \(attributePointsRemaining)")
            Text("Karma: \(character.karma)")
            Button("Reset Attributes") {
                let attributes = ["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"]
                for attr in attributes {
                    character.attributes[attr] = attributeRange(for: attr).lowerBound
                }
                if let priority = character.priority,
                   let attributePriority = dataManager.priorityData.attributes[priority.attributes] {
                    attributePointsRemaining = attributePriority
                }
                maxAttributeError = nil
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func initializeAttributes() {
        guard let priority = character.priority else {
            errorMessage = "Error: Character priority not set. Please complete priority selection before proceeding."
            return
        }
        guard let attributePriority = dataManager.priorityData.attributes[priority.attributes] else {
            errorMessage = "Error: Invalid attributes priority selected. Please select a valid attributes priority."
            return
        }
        if !isMetatypeSet {
            errorMessage = "Error: Character metatype not set. Please select a valid metatype."
            return
        }
        if !isMetatypeValid {
            errorMessage = "Error: Invalid metatype selected. Please select a valid metatype."
            return
        }
        if dataManager.metatypes.isEmpty {
            errorMessage = "Error: No metatype data available. Please ensure metatypes.json contains valid metatype entries."
            return
        }
        if dataManager.priorityData.attributes.isEmpty {
            errorMessage = "Error: No attributes priority data available. Please ensure priorities.json contains valid attributes priority entries."
            return
        }

        // Initialize attributes to metatype minimums if unset
        let attributes = ["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"]
        for attr in attributes {
            if character.attributes[attr] == nil {
                character.attributes[attr] = attributeRange(for: attr).lowerBound
            }
        }

        // Calculate points used and set remaining points
        let pointsUsed = attributes.reduce(0) { total, attr in
            let currentValue = character.attributes[attr] ?? attributeRange(for: attr).lowerBound
            let minValue = attributeRange(for: attr).lowerBound
            return total + (currentValue - minValue)
        }
        attributePointsRemaining = attributePriority - pointsUsed

        // Validate one attribute at maximum rule
        let maxedAttributes = attributes.filter { attr in
            let value = character.attributes[attr] ?? attributeRange(for: attr).lowerBound
            return value == attributeRange(for: attr).upperBound
        }
        if maxedAttributes.count > 1 {
            maxAttributeError = "Error: Only one attribute can be at its racial maximum. Please downgrade another attribute."
        } else {
            maxAttributeError = nil
        }
    }
}

struct AttributesView_Previews: PreviewProvider {
    static var previews: some View {
        AttributesView(character: .constant(Character(
            name: "Test",
            metatype: "Human",
            priority: Character.PrioritySelection(
                metatype: "A",
                attributes: "B",
                skills: "C",
                magic: "D",
                resources: "E"
            ),
            attributes: ["Body": 3, "Agility": 4],
            skills: [:],
            specializations: [:],
            karma: 5, // Low karma to test warning
            nuyen: 1000,
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
        )))
        .environmentObject({
            let dm = DataManager()
            dm.priorityData = PriorityData(
                metatype: [:],
                attributes: [
                    "B": 20
                ],
                skills: [:],
                magic: [:],
                resources: [:]
            )
            dm.metatypes = [
                Metatype(
                    id: "1",
                    name: "Human",
                    karma: "0",
                    category: "Human",
                    bodmin: "1", bodmax: "6", bodaug: "9",
                    agimin: "1", agimax: "6", agiaug: "9",
                    reamin: "1", reamax: "6", reaaug: "9",
                    strmin: "1", strmax: "6", straug: "9",
                    chamin: "1", chamax: "6", chaaug: "9",
                    intmin: "1", intmax: "6", intaug: "9",
                    logmin: "1", logmax: "6", logaug: "9",
                    wilmin: "1", wilmax: "6", wilaug: "9",
                    inimin: "1", inimax: "6", iniaug: "9",
                    edgmin: "2", edgmax: "7", edgaug: "9",
                    magmin: "0", magmax: "0", magaug: "0",
                    resmin: "0", resmax: "0", resaug: "0",
                    essmin: "6", essmax: "6", essaug: "6",
                    depmin: "0", depmax: "0", depaug: "0",
                    walk: "10", run: "20", sprint: "30",
                    bonus: nil,
                    source: "Core",
                    page: "65",
                    metavariants: []
                )
            ]
            dm.errors = [:]
            return dm
        }())
    }
}
