//
//  CharacterCreationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var dataManager: DataManager
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
    @State private var selectedMetatypePriority: String = ""
    let onComplete: (Character) -> Void
    
    enum CreationStep {
        case priority, metatype, attributes, skills, magic, resources, qualities, contacts, sourcebooks
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case .priority:
                    PrioritySelectionView(
                        character: $character,
                        selectedMetatypePriority: $selectedMetatypePriority,
                        onComplete: {
                            currentStep = .metatype
                        }
                    )
                case .metatype:
                    MetatypeSelectionView(
                        character: $character,
                        selectedMetatypePriority: $selectedMetatypePriority,
                        onComplete: {
                            currentStep = .attributes
                        },
                        onPrevious: {
                            currentStep = .priority
                        }
                    )
                case .attributes:
                    AttributesAllocationView(
                        character: $character,
                        onComplete: {
                            currentStep = .skills
                        }
                    )
                case .skills:
                    SkillsAllocationView(
                        character: $character,
                        onComplete: {
                            currentStep = .magic
                        }
                    )
                case .magic:
                    MagicSelectionView(
                        character: $character,
                        onComplete: {
                            currentStep = .resources
                        }
                    )
                case .resources:
                    ResourcesAllocationView(
                        character: $character,
                        onComplete: {
                            currentStep = .qualities
                        }
                    )
                case .qualities:
                    QualitiesSelectionView(
                        character: $character,
                        onComplete: {
                            currentStep = .contacts
                        }
                    )
                case .contacts:
                    ContactsSelectionView(
                        character: $character,
                        onComplete: {
                            currentStep = .sourcebooks
                        }
                    )
                case .sourcebooks:
                    SourcebookSelectionView(
                        character: $character,
                        onComplete: {
                            onComplete(character)
                        }
                    )
                }
                
                HStack {
                    if currentStep != .priority {
                        Button("Previous") {
                            switch currentStep {
                            case .metatype: currentStep = .priority
                            case .attributes: currentStep = .metatype
                            case .skills: currentStep = .attributes
                            case .magic: currentStep = .skills
                            case .resources: currentStep = .magic
                            case .qualities: currentStep = .resources
                            case .contacts: currentStep = .qualities
                            case .sourcebooks: currentStep = .contacts
                            case .priority: break
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Character Creation")
        }
    }
}

struct CharacterCreationView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreationView(onComplete: { _ in })
            .environmentObject(DataManager())
    }
}
