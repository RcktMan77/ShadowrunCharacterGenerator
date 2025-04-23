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
                                Text(NSLocalizedString("Effect", comment: "Label")) + Text(": \(component.effect)")
                                Text(NSLocalizedString("Availability", comment: "Label")) + Text(": \(component.availability)")
                            }
                            Spacer()
                            Text("\(component.cost) Nuyen")
                            Button(NSLocalizedString("Buy", comment: "Button")) {
                                if character.nuyen >= component.cost {
                                    character.nuyen -= component.cost
                                    character.gear[component.name, default: 0] += 1
                                }
                            }
                            .disabled(character.nuyen < component.cost)
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
            martialArts: []
        )))
        .environmentObject(DataManager())
    }
}
