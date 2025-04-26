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
        priority: nil,
        attributes: [:],
        skills: [:],
        specializations: [:],
        karma: 25,
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
    @State private var currentStep: CreationStep = .metatype // Start with metatype
    @State private var selectedMetatypePriority: String = ""
    @State private var selectedMetatype: String = "" // Store selected metatype
    let onComplete: (Character) -> Void

    enum CreationStep: CaseIterable {
        case metatype, priorities, attributes, skills, magic, resources, qualities, contacts, sourcebooks
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Progress Indicator
                HStack {
                    ForEach(CreationStep.allCases, id: \.self) { step in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(currentStep == step ? .blue : .gray)
                    }
                }
                .padding()

                // Creation Steps
                switch currentStep {
                case .metatype:
                    MetatypeSelectionView(
                        character: $character,
                        selectedMetatype: $selectedMetatype,
                        onComplete: {
                            currentStep = .priorities
                        }
                    )
                case .priorities:
                    PrioritySelectionView(
                        character: $character,
                        selectedMetatypePriority: $selectedMetatypePriority,
                        selectedMetatype: selectedMetatype,
                        onComplete: {
                            currentStep = .attributes
                        },
                        onPrevious: {
                            currentStep = .metatype
                        }
                    )
                case .attributes:
                    AttributesAllocationView(
                        character: $character,
                        onComplete: {
                            currentStep = .skills
                        },
                        onPrevious: {
                            currentStep = .priorities
                        }
                    )
                case .skills:
                    SkillsAllocationView(
                        character: $character,
                        onComplete: {
                            currentStep = .magic
                        },
                        onPrevious: {
                            currentStep = .attributes
                        }
                    )
                case .magic:
                    MagicSelectionView(
                        character: $character,
                        onComplete: {
                            currentStep = .resources
                        },
                        onPrevious: {
                            currentStep = .skills
                        }
                    )
                case .resources:
                    ResourcesAllocationView(
                        character: $character,
                        onComplete: {
                            currentStep = .qualities
                        },
                        onPrevious: {
                            currentStep = .magic
                        }
                    )
                case .qualities:
                    QualitiesSelectionView(
                        character: $character,
                        onComplete: {
                            currentStep = .contacts
                        },
                        onPrevious: {
                            currentStep = .resources
                        }
                    )
                case .contacts:
                    ContactsSelectionView(
                        character: $character,
                        onComplete: {
                            currentStep = .sourcebooks
                        },
                        onPrevious: {
                            currentStep = .qualities
                        }
                    )
                case .sourcebooks:
                    SourcebookSelectionView(
                        character: $character,
                        onComplete: {
                            onComplete(character)
                        },
                        onPrevious: {
                            currentStep = .contacts
                        }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if currentStep != .metatype && currentStep != .priorities && currentStep != .attributes && currentStep != .skills {
                        Button("Next") {
                            switch currentStep {
                            case .magic: currentStep = .resources
                            case .resources: currentStep = .qualities
                            case .qualities: currentStep = .contacts
                            case .contacts: currentStep = .sourcebooks
                            case .sourcebooks: onComplete(character)
                            default: break
                            }
                        }
                        .disabled(!isStepValid())
                    }
                }
                ToolbarItem(placement: .navigation) {
                    if currentStep != .metatype && currentStep != .priorities && currentStep != .attributes && currentStep != .skills {
                        Button("Previous") {
                            switch currentStep {
                            case .magic: currentStep = .skills
                            case .resources: currentStep = .magic
                            case .qualities: currentStep = .resources
                            case .contacts: currentStep = .qualities
                            case .sourcebooks: currentStep = .contacts
                            default: break
                            }
                        }
                    }
                }
            }
        }
    }

    private func isStepValid() -> Bool {
        switch currentStep {
        case .metatype:
            return !selectedMetatype.isEmpty
        case .priorities:
            return character.priority != nil
        case .attributes:
            return character.attributes.values.reduce(0, +) >= (dataManager.priorityData.attributes[character.priority?.attributes ?? "E"] ?? 12)
        case .skills, .magic, .resources, .qualities, .contacts, .sourcebooks:
            return true // Simplified for brevity; add specific validation if needed
        }
    }
}

struct CharacterCreationView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreationView { _ in }
            .environmentObject({
                let dm = DataManager()
                dm.priorityData = PriorityData(
                    metatype: [
                        "A": [MetatypeOption(name: "Human", specialAttributePoints: 9, karma: 0), MetatypeOption(name: "Elf", specialAttributePoints: 8, karma: 0)],
                        "B": [MetatypeOption(name: "Dwarf", specialAttributePoints: 7, karma: 0)],
                        "C": [MetatypeOption(name: "Ork", specialAttributePoints: 7, karma: 0)],
                        "D": [MetatypeOption(name: "Troll", specialAttributePoints: 5, karma: 0)],
                        "E": [MetatypeOption(name: "Human", specialAttributePoints: 1, karma: 0)]
                    ],
                    attributes: ["A": 24, "B": 20, "C": 16, "D": 14, "E": 12],
                    skills: [
                        "A": SkillPriority(skillPoints: 46, skillGroupPoints: 10),
                        "B": SkillPriority(skillPoints: 36, skillGroupPoints: 5),
                        "C": SkillPriority(skillPoints: 28, skillGroupPoints: 2),
                        "D": SkillPriority(skillPoints: 22, skillGroupPoints: 0),
                        "E": SkillPriority(skillPoints: 18, skillGroupPoints: 0)
                    ],
                    magic: [
                        "E-Mundane": MagicPriority(type: "Mundane", points: 0, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil)
                    ],
                    resources: ["A": 450000, "B": 275000, "C": 140000, "D": 50000, "E": 6000]
                )
                dm.metatypes = [
                    Metatype(
                        id: "1",
                        name: "Human",
                        karma: "0",
                        category: "Human",
                        bodmin: "1", bodmax: "6", bodaug: "9",
                        agimin: "1", agimax: "6", agiaug: "9",
                        reamin: "1", reamax: "6", reaaug: "9",
                        strmin: "1", strmax: "6", straug: "9",
                        chamin: "1", chamax: "6", chaaug: "9",
                        intmin: "1", intmax: "6", intaug: "9",
                        logmin: "1", logmax: "6", logaug: "9",
                        wilmin: "1", wilmax: "6", wilaug: "9",
                        inimin: "1", inimax: "6", iniaug: "9",
                        edgmin: "2", edgmax: "7", edgaug: "9",
                        magmin: "0", magmax: "0", magaug: "0",
                        resmin: "0", resmax: "0", resaug: "0",
                        essmin: "6", essmax: "6", essaug: "6",
                        depmin: "0", depmax: "0", depaug: "0",
                        walk: "10", run: "20", sprint: "30",
                        bonus: nil,
                        source: "Core",
                        page: "65",
                        metavariants: []
                    ),
                    Metatype(
                        id: "2",
                        name: "Troll",
                        karma: "0",
                        category: "Troll",
                        bodmin: "5", bodmax: "9", bodaug: "12",
                        agimin: "1", agimax: "6", agiaug: "9",
                        reamin: "1", reamax: "6", reaaug: "9",
                        strmin: "5", strmax: "9", straug: "12",
                        chamin: "1", chamax: "5", chaaug: "8",
                        intmin: "1", intmax: "5", intaug: "8",
                        logmin: "1", logmax: "5", logaug: "8",
                        wilmin: "1", wilmax: "6", wilaug: "9",
                        inimin: "1", inimax: "6", iniaug: "9",
                        edgmin: "1", edgmax: "6", edgaug: "9",
                        magmin: "0", magmax: "0", magaug: "0",
                        resmin: "0", resmax: "0", resaug: "0",
                        essmin: "6", essmax: "6", essaug: "6",
                        depmin: "0", depmax: "0", depaug: "0",
                        walk: "10", run: "20", sprint: "30",
                        bonus: nil,
                        source: "Core",
                        page: "65",
                        metavariants: []
                    )
                ]
                return dm
            }())
    }
}
