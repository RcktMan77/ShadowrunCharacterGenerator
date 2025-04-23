//
//  ContactsSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct ContactsSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    @State private var contactPointsRemaining: Int = 6 // Example; based on Charisma
    
    var body: some View {
        Form {
            ForEach(dataManager.contacts, id: \.name) { contact in
                HStack {
                    Text(contact.name)
                    Stepper(value: Binding(
                        get: { character.contacts[contact.name]?.connection ?? 1 },
                        set: { newValue in
                            let delta = newValue - (character.contacts[contact.name]?.connection ?? 1)
                            if contactPointsRemaining >= delta && newValue >= 1 {
                                character.contacts[contact.name] = Contact(name: contact.name, connection: newValue, loyalty: 1)
                                contactPointsRemaining -= delta
                            }
                        }
                    ), in: 1...6) {
                        Text("Connection: \(character.contacts[contact.name]?.connection ?? 1)")
                    }
                }
            }
            Text("Contact Points Remaining: \(contactPointsRemaining)")
            Button("Next") {
                onComplete()
            }
        }
        .navigationTitle("Select Contacts")
    }
}
