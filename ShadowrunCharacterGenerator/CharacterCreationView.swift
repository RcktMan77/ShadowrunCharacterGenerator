//
//  CharacterCreationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

struct CharacterCreationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    
    enum CreationStep {
        case prioritySelection, metatypeSelection, attributesAllocation, skillsAllocation, magicSelection, resourcesAllocation
    }
    
    @State private var step: CreationStep = .prioritySelection
    @State private var prioritySelection: PrioritySelection?
    
    var body: some View {
        switch step {
        case .prioritySelection:
            PrioritySelectionView { selection in
                prioritySelection = selection
                step = .metatypeSelection
            }
        case .metatypeSelection:
            MetatypeSelectionView(prioritySelection: prioritySelection!) { metatype in
                character.metatype = metatype
                step = .attributesAllocation
            }
        case .attributesAllocation:
            AttributesAllocationView(prioritySelection: prioritySelection!, attributes: $character.attributes) {
                step = .skillsAllocation
            }
        case .skillsAllocation:
            SkillsAllocationView(prioritySelection: prioritySelection!, skills: $character.skills) {
                step = .magicSelection
            }
        case .magicSelection:
            MagicSelectionView(prioritySelection: prioritySelection!) {
                step = .resourcesAllocation
            }
        case .resourcesAllocation:
            ResourcesAllocationView(prioritySelection: prioritySelection!) {
                // Creation complete
            }
        }
    }
}

// MetatypeSelectionView.swift
struct MetatypeSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    var prioritySelection: PrioritySelection
    var onSelect: (String) -> Void
    
    var body: some View {
        let availableMetatypes = dataManager.priorityData.Metatype[prioritySelection.metatype.rawValue] ?? []
        List(availableMetatypes, id: \.metatype) { option in
            Button(option.metatype) {
                onSelect(option.metatype)
            }
        }
    }
}

// AttributesAllocationView.swift
struct AttributesAllocationView: View {
    @EnvironmentObject var dataManager: DataManager
    var prioritySelection: PrioritySelection
    @Binding var attributes: [String: Int]
    var onComplete: () -> Void
    
    @State private var pointsRemaining: Int
    
    init(prioritySelection: PrioritySelection, attributes: Binding<[String: Int]>, onComplete: @escaping () -> Void) {
        self.prioritySelection = prioritySelection
        self._attributes = attributes
        self.onComplete = onComplete
        self._pointsRemaining = State(initialValue: dataManager.priorityData.Attributes[prioritySelection.attributes.rawValue] ?? 0)
        if attributes.wrappedValue.isEmpty {
            attributes.wrappedValue = ["Body": 1, "Agility": 1, "Reaction": 1, "Strength": 1, "Willpower": 1, "Logic": 1, "Intuition": 1, "Charisma": 1]
            self._pointsRemaining = State(initialValue: (dataManager.priorityData.Attributes[prioritySelection.attributes.rawValue] ?? 0) - 8)
        }
    }
    
    var body: some View {
        Form {
            ForEach(attributes.keys.sorted(), id: \.self) { attr in
                HStack {
                    Text(attr)
                    Stepper(value: Binding(
                        get: { attributes[attr] ?? 1 },
                        set: { newValue in
                            let delta = newValue - (attributes[attr] ?? 1)
                            if pointsRemaining >= delta && newValue >= 1 && newValue <= 12 {
                                attributes[attr] = newValue
                                pointsRemaining -= delta
                            }
                        }
                    ), in: 1...12) {
                        Text("\(attributes[attr] ?? 1)")
                    }
                }
            }
            Text("Points Remaining: \(pointsRemaining)")
            Button("Next") {
                onComplete()
            }
            .disabled(pointsRemaining > 0)
        }
    }
}
