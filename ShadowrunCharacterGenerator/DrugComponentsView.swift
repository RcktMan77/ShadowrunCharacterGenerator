//
//  DrugComponentsView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct DrugComponentsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    
    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("Drug Components", comment: "Section header"))) {
                if dataManager.drugComponents.isEmpty {
                    Text(NSLocalizedString("No drug components available", comment: "Empty message"))
                } else {
                    ForEach(dataManager.drugComponents, id: \.name) { component in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(NSLocalizedString(component.name, comment: "Component name"))
                                    .font(.headline)
                                Text(NSLocalizedString("Effect", comment: "Label")) + Text(": \(effectSummary(for: component))")
                                Text(NSLocalizedString("Availability", comment: "Label")) + Text(": \(component.availability)")
                            }
                            Spacer()
                            Text("\(component.cost) Nuyen")
                            Button(NSLocalizedString("Buy", comment: "Button")) {
                                if let cost = Int(component.cost), character.nuyen >= cost {
                                    character.nuyen -= cost
                                    character.gear[component.name, default: 0] += 1
                                }
                            }
                            .disabled(!canAfford(component))
                        }
                    }
                }
            }
            Section {
                Text(NSLocalizedString("Nuyen Remaining", comment: "Label")) + Text(": \(character.nuyen)")
            }
        }
        .navigationTitle(NSLocalizedString("Drug Components", comment: "Title"))
    }
    
    private func effectSummary(for component: DrugComponent) -> String {
        guard let effects = component.effects, let firstEffect = effects.first else {
            return "None"
        }
        if let attributes = firstEffect.attribute, let firstAttr = attributes.first {
            return "\(firstAttr.name): \(firstAttr.value)"
        } else if let quality = firstEffect.quality {
            return quality.name
        }
        return "Level \(firstEffect.level)"
    }
    
    private func canAfford(_ component: DrugComponent) -> Bool {
        if let cost = Int(component.cost) {
            return character.nuyen >= cost
        }
        return false
    }
}

struct DrugComponentsView_Previews: PreviewProvider {
    static var previews: some View {
        DrugComponentsView(character: .constant(Character(
            name: "Test",
            metatype: "Human",
            attributes: [:],
            skills: [:],
            karma: 0,
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
            dm.drugComponents = [
                DrugComponent(
                    id: "1",
                    name: "Stimulant",
                    category: "Chemical",
                    effects: [
                        Effect(
                            level: "1",
                            attribute: [Attribute(name: "Reaction", value: "+1")],
                            quality: nil
                        )
                    ],
                    availability: "6",
                    cost: "100",
                    rating: "1",
                    threshold: "2",
                    source: "Core",
                    page: "123"
                )
            ]
            return dm
        }())
    }
}
