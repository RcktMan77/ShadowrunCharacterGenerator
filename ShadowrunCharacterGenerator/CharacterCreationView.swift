//
//  CharacterCreationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct CharacterCreationView: View {
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
    @State private var currentStep: CreationStep = .priority
    @State private var isCreationComplete = false
    @EnvironmentObject var dataManager: DataManager
    
    enum CreationStep {
        case priority, metatype, attributes, skills, magic, resources, qualities, contacts, sourcebooks
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case .priority:
                    PrioritySelectionView(character: $character, onComplete: {
                        currentStep = .metatype
                    })
                case .metatype:
                    MetatypeSelectionView(character: $character, onComplete: {
                        currentStep = .attributes
                    })
                case .attributes:
                    AttributesAllocationView(character: $character, onComplete: {
                        currentStep = .skills
                    })
                case .skills:
                    SkillsAllocationView(character: $character, onComplete: {
                        currentStep = .magic
                    })
                case .magic:
                    MagicSelectionView(character: $character, onComplete: {
                        currentStep = .resources
                    })
                case .resources:
                    ResourcesAllocationView(character: $character, onComplete: {
                        currentStep = .qualities
                    })
                case .qualities:
                    QualitiesSelectionView(character: $character, onComplete: {
                        currentStep = .contacts
                    })
                case .contacts:
                    ContactsSelectionView(character: $character, onComplete: {
                        currentStep = .sourcebooks
                    })
                case .sourcebooks:
                    SourcebookSelectionView(character: $character, onComplete: {
                        isCreationComplete = true
                    })
                }
                Button("Next") {
                    switch currentStep {
                    case .priority: currentStep = .metatype
                    case .metatype: currentStep = .attributes
                    case .attributes: currentStep = .skills
                    case .skills: currentStep = .magic
                    case .magic: currentStep = .resources
                    case .resources: currentStep = .qualities
                    case .qualities: currentStep = .contacts
                    case .contacts: currentStep = .sourcebooks
                    case .sourcebooks: isCreationComplete = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .disabled(currentStep == .sourcebooks && character.sourcebooks.isEmpty)
            }
            .navigationTitle("Character Creation")
            .sheet(isPresented: $isCreationComplete) {
                CharacterSheetView(character: character)
            }
        }
    }
}

struct CharacterCreationView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreationView()
            .environmentObject(DataManager())
    }
}
