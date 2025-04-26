//
//  QualitiesSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct QualitiesSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    let onPrevious: (() -> Void)?
    @State private var selectedQualities: [String: Int] = [:]
    @State private var karmaBalance: Int = 0
    @State private var errorMessage: String?
    @State private var showingDescription: Bool = false
    @State private var selectedQuality: Quality?
    private let maxKarma: Int = 25 // Shadowrun 5E limit
    private let karmaWarningThreshold: Int = 5 // Warn within 5 of ±25

    private var isKarmaApproachingLimit: Bool {
        abs(karmaBalance) >= maxKarma - karmaWarningThreshold && abs(karmaBalance) <= maxKarma
    }

    private var isNegativeKarma: Bool {
        character.karma + karmaBalance < 0
    }

    private var isPriorityValid: Bool {
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
            if isPriorityValid && errorMessage == nil && !isNegativeKarma {
                qualitiesSection
                balanceSection
            }
        }
        .navigationTitle("Select Qualities")
        .onAppear {
            initializeQualities()
        }
        .popover(isPresented: $showingDescription) {
            if let quality = selectedQuality {
                qualityDescriptionView(quality: quality)
                    .frame(minWidth: 300, minHeight: 200)
                    .padding()
            }
        }
    }

    private var errorSection: some View {
        Group {
            if !isPriorityValid {
                Text("Error: Character priority selection is missing. Please complete priority selection first.")
                    .foregroundColor(.red)
                    .padding()
            }
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.errors["qualities"] != nil {
                Text("Error: Failed to load qualities data. Please ensure qualities.json is present and correctly formatted.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.qualities.isEmpty {
                Text("Error: No qualities data available. Please ensure qualities.json contains valid quality entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if isNegativeKarma {
                Text("Error: Karma cannot be negative. Please remove some positive qualities or add negative qualities.")
                    .foregroundColor(.red)
                    .padding()
            }
            if isKarmaApproachingLimit {
                Text("Warning: Karma balance nearing limit (±25). Consider reserving karma for other purchases.")
                    .foregroundColor(.orange)
                    .padding()
            }
        }
    }

    private var qualitiesSection: some View {
        Section(header: Text("Qualities")) {
            ForEach(dataManager.qualities, id: \.name) { quality in
                if let karmaCost = Int(quality.karma) {
                    HStack {
                        Text(quality.name)
                        Text("\(karmaCost) Karma")
                        Spacer()
                        Button(action: {
                            selectedQuality = quality
                            showingDescription = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                        Button(selectedQualities[quality.name] == nil ? (quality.category == "Positive" ? "Add" : "Take") : "Remove") {
                            if selectedQualities[quality.name] == nil {
                                let cost = quality.category == "Positive" ? karmaCost : -karmaCost
                                let newBalance = karmaBalance + cost
                                if abs(newBalance) <= maxKarma && character.karma + newBalance >= 0 {
                                    selectedQualities[quality.name] = karmaCost
                                    karmaBalance = newBalance
                                }
                            } else {
                                let cost = quality.category == "Positive" ? karmaCost : -karmaCost
                                selectedQualities.removeValue(forKey: quality.name)
                                karmaBalance -= cost
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedQualities[quality.name] == nil &&
                                  (abs(karmaBalance + (quality.category == "Positive" ? karmaCost : -karmaCost)) > maxKarma ||
                                   character.karma + karmaBalance + (quality.category == "Positive" ? karmaCost : -karmaCost) < 0))
                    }
                } else {
                    Text("Error: Invalid karma cost for \(quality.name). Please ensure qualities.json contains valid karma values.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
    }

    private var balanceSection: some View {
        Section {
            Text("Karma Balance: \(karmaBalance)")
            Text("Total Karma Remaining: \(character.karma + karmaBalance)")
            HStack {
                if onPrevious != nil {
                    Button("Previous") {
                        onPrevious?()
                    }
                    .buttonStyle(.bordered)
                }
                Button("Reset") {
                    selectedQualities.removeAll()
                    karmaBalance = 0
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Next") {
                    character.qualities = selectedQualities
                    character.karma += karmaBalance
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isNegativeKarma || errorMessage != nil || dataManager.qualities.isEmpty || !isPriorityValid)
            }
            .padding()
        }
    }

    private func qualityDescriptionView(quality: Quality) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(quality.name)
                .font(.headline)
            Text("Category: \(quality.category)")
            Text("Karma Cost: \(quality.karma)")
            if let limit = quality.limit {
                Text("Limit: \(limit)")
            }
            Text("Source: \(quality.source), Page \(quality.page)")
            if let bonus = quality.bonus {
                Text("Bonus: \(bonusDescription(bonus))")
            }
            Spacer()
            Button("Close") {
                showingDescription = false
                selectedQuality = nil
            }
            .buttonStyle(.bordered)
        }
    }

    private func bonusDescription(_ bonus: [String: AnyCodable]) -> String {
        bonus.map { key, value in
            switch value.value {
            case let dict as [String: String]:
                let details = dict.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
                return "\(key)(\(details))"
            case let str as String:
                return "\(key): \(str)"
            case let nestedDict as [String: Any]:
                let details = nestedDict.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
                return "\(key)(\(details))"
            default:
                return "\(key): Unknown"
            }
        }.joined(separator: "; ")
    }

    private func initializeQualities() {
        if !isPriorityValid {
            errorMessage = "Error: Character priority selection is missing. Please complete priority selection first."
            return
        }
        if dataManager.qualities.isEmpty {
            errorMessage = "Error: No qualities data available. Please ensure qualities.json contains valid quality entries."
            return
        }
        selectedQualities = character.qualities
        karmaBalance = character.qualities.reduce(0) { total, quality in
            let cost = quality.value
            return total + (cost > 0 ? cost : -cost)
        }
        // Validate karma costs
        for quality in dataManager.qualities {
            if Int(quality.karma) == nil {
                errorMessage = "Error: Invalid karma cost for \(quality.name). Please ensure qualities.json contains valid karma values."
                return
            }
        }
    }
}

struct QualitiesSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        QualitiesSelectionView(
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
                karma: 25,
                nuyen: 0,
                gear: [:],
                qualities: ["High Pain Tolerance": 7],
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
            dm.qualities = [
                Quality(
                    id: "1",
                    name: "High Pain Tolerance",
                    karma: "7",
                    category: "Positive",
                    limit: nil,
                    bonus: ["damage resistance": AnyCodable(["value": "+1"])],
                    source: "Core",
                    page: "74"
                ),
                Quality(
                    id: "2",
                    name: "Allergy (Mild, Common)",
                    karma: "5",
                    category: "Negative",
                    limit: nil,
                    bonus: nil,
                    source: "Core",
                    page: "81"
                ),
                Quality(
                    id: "3",
                    name: "Ambidextrous",
                    karma: "4",
                    category: "Positive",
                    limit: nil,
                    bonus: ["off-hand penalty": AnyCodable(["value": "none"])],
                    source: "Core",
                    page: "71"
                )
            ]
            dm.errors = [:]
            return dm
        }())
    }
}
