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
        martialArts: [],
        sourcebooks: []
    )
    @State private var isCharacterSheetPresented = false
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Create Character") {
                    CharacterCreationView(onComplete: { createdCharacter in
                        character = createdCharacter
                        isCharacterSheetPresented = true
                    })
                }
                NavigationLink("Character Sheet") {
                    CharacterSheetView(character: character)
                }
                NavigationLink("Sourcebooks") {
                    SourcebookSelectionView(character: $character, onComplete: {})
                }
                NavigationLink("Qualities") {
                    QualitiesSelectionView(character: $character, onComplete: {})
                }
                NavigationLink("Gear") {
                    GearSelectionView(character: $character)
                }
                NavigationLink("Contacts") {
                    ContactsSelectionView(character: $character, onComplete: {})
                }
                NavigationLink("Progression") {
                    ProgressionView(character: $character)
                }
                NavigationLink("Martial Arts") {
                    MartialArtsView(character: $character)
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Shadowrun Character Generator")
            
            Text("Select an option from the sidebar")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .environmentObject(dataManager)
        .sheet(isPresented: $isCharacterSheetPresented) {
            CharacterSheetView(character: character)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager())
    }
}
