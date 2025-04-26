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
    let onPrevious: (() -> Void)?
    @State private var contactPointsRemaining: Int
    @State private var errorMessage: String?

    init(character: Binding<Character>, onComplete: @escaping () -> Void, onPrevious: (() -> Void)? = nil) {
        self._character = character
        self.onComplete = onComplete
        self.onPrevious = onPrevious
        let charisma = character.wrappedValue.attributes["Charisma"] ?? 1
        self._contactPointsRemaining = State(initialValue: charisma * 3)
    }

    var body: some View {
        Form {
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            ForEach(dataManager.contacts, id: \.name) { contact in
                VStack(alignment: .leading) {
                    Text(contact.name)
                    HStack {
                        Text("Connection")
                        Stepper(value: Binding(
                            get: { character.contacts[contact.name]?.connection ?? 1 },
                            set: { newValue in
                                let delta = newValue - (character.contacts[contact.name]?.connection ?? 1)
                                if contactPointsRemaining >= delta && newValue >= 1 && newValue <= 6 {
                                    character.contacts[contact.name] = Contact(
                                        name: contact.name,
                                        connection: newValue,
                                        loyalty: character.contacts[contact.name]?.loyalty ?? 1
                                    )
                                    contactPointsRemaining -= delta
                                }
                            }
                        ), in: 1...6) {
                            Text("\(character.contacts[contact.name]?.connection ?? 1)")
                        }
                    }
                    HStack {
                        Text("Loyalty")
                        Stepper(value: Binding(
                            get: { character.contacts[contact.name]?.loyalty ?? 1 },
                            set: { newValue in
                                let delta = newValue - (character.contacts[contact.name]?.loyalty ?? 1)
                                if contactPointsRemaining >= delta && newValue >= 1 && newValue <= 6 {
                                    character.contacts[contact.name] = Contact(
                                        name: contact.name,
                                        connection: character.contacts[contact.name]?.connection ?? 1,
                                        loyalty: newValue
                                    )
                                    contactPointsRemaining -= delta
                                }
                            }
                        ), in: 1...6) {
                            Text("\(character.contacts[contact.name]?.loyalty ?? 1)")
                        }
                    }
                }
            }
            Section {
                Text("Contact Points Remaining: \(contactPointsRemaining)")
                HStack {
                    if onPrevious != nil {
                        Button("Previous") {
                            onPrevious?()
                        }
                        .buttonStyle(.bordered)
                    }
                    Spacer()
                    Button("Next") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(errorMessage != nil || dataManager.contacts.isEmpty)
                }
                .padding()
            }
        }
        .navigationTitle("Select Contacts")
        .onAppear {
            if dataManager.contacts.isEmpty {
                errorMessage = "Failed to load contacts data."
            }
            // Initialize with existing contacts
            contactPointsRemaining -= character.contacts.values.reduce(0) { $0 + $1.connection + $1.loyalty }
        }
    }
}

struct ContactsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsSelectionView(
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
                attributes: ["Charisma": 4],
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
            dm.contacts = [
                Contact(name: "Fixer", connection: 1, loyalty: 1),
                Contact(name: "Hacker", connection: 1, loyalty: 1)
            ]
            dm.errors = [:]
            return dm
        }())
    }
}
