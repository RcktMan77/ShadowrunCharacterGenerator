//
//  ContentView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dataManager = DataManager()
    @State private var character = Character(
        name: "",
        metatype: "",
        attributes: [:],
        skills: [:],
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
        martialArts: []
    )
    @State private var step: CreationStep = .priority
    
    enum CreationStep {
        case priority, metatype, attributes, skills, magic, resources, qualities, contacts, complete
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Create Character", destination: characterCreationView)
                NavigationLink("Character Sheet", destination: CharacterSheetView(character: $character))
                NavigationLink("Sourcebooks", destination: SourcebookSelectionView())
                NavigationLink("Qualities", destination: QualitiesSelectionView(character: $character))
                NavigationLink("Gear", destination: GearSelectionView(character: $character))
                NavigationLink("Contacts", destination: ContactsSelectionView(character: $character))
                NavigationLink("Progression", destination: ProgressionView(character: $character))
                NavigationLink("Martial Arts", destination: MartialArtsView(character: $character))
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Shadowrun Character Generator")
            
            Text("Select an option from the sidebar")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .environmentObject(dataManager)
    }
    
    @ViewBuilder
    var characterCreationView: some View {
        switch step {
        case .priority:
            PrioritySelectionView(character: $character) {
                step = .metatype
            }
        case .metatype:
            MetatypeSelectionView(character: $character) {
                step = .attributes
            }
        case .attributes:
            AttributesAllocationView(character: $character) {
                step = .skills
            }
        case .skills:
            SkillsAllocationView(character: $character) {
                step = .magic
            }
        case .magic:
            MagicSelectionView(character: $character) {
                step = .resources
            }
        case .resources:
            ResourcesAllocationView(character: $character) {
                step = .qualities
            }
        case .qualities:
            QualitiesSelectionView(character: $character) {
                step = .contacts
            }
        case .contacts:
            ContactsSelectionView(character: $character) {
                step = .complete
            }
        case .complete:
            CharacterSheetView(character: $character)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
