//
//  AttributesAllocationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct AttributesAllocationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    let onPrevious: (() -> Void)?
    @State private var errorMessage: String?
    @State private var karmaPurchasedAttributes: [String: Int] = [:] // Tracks karma-purchased points per attribute
    
    private let physicalAttributes = ["Body", "Agility", "Reaction", "Strength"]
    private let mentalAttributes = ["Charisma", "Intuition", "Logic", "Willpower"]
    
    private var totalPointsAllocated: Int {
        character.attributes.values.reduce(0, +)
    }
    
    private var pointsRemaining: Int {
        let totalPoints = dataManager.priorityData.attributes[character.priority?.attributes ?? "E"] ?? 12
        let pointsUsed = character.attributes.map { (key, value) in
            let metatype = dataManager.metatypes.first(where: { $0.name == character.metatype })
            let min = metatype != nil ? attributeMin(attribute: key, metatype: metatype!) : 1
            return max(0, value - min - (karmaPurchasedAttributes[key] ?? 0))
        }.reduce(0, +)
        return max(0, totalPoints - pointsUsed)
    }
    
    private var karmaSpent: Int {
        karmaPurchasedAttributes.values.reduce(0, +) * 5
    }
    
    private var minPointsRequired: Int {
        dataManager.priorityData.attributes[character.priority?.attributes ?? "E"] ?? 12
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Form {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.vertical, 10)
                } else if dataManager.metatypes.isEmpty {
                    Text("No metatype data available. Please try again.")
                        .foregroundColor(.red)
                        .padding(.vertical, 10)
                } else {
                    Section {
                        VStack(spacing: 10) {
                            if let metatype = dataManager.metatypes.first(where: { $0.name == character.metatype }) {
                                Section(header: Text("Physical Attributes")) {
                                    ForEach(physicalAttributes, id: \.self) { attribute in
                                        attributeRow(attribute: attribute, metatype: metatype)
                                    }
                                }
                                
                                Section(header: Text("Mental Attributes")) {
                                    ForEach(mentalAttributes, id: \.self) { attribute in
                                        attributeRow(attribute: attribute, metatype: metatype)
                                    }
                                }
                                
                                Section(header: Text("Special Attributes")) {
                                    attributeRow(attribute: "Edge", metatype: metatype)
                                }
                            }
                        }
                        .padding(.all, 10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.vertical, 10)
                    
                    Section {
                        HStack {
                            Text("Points Allocated: \(totalPointsAllocated)")
                            Spacer()
                            Text("Points Remaining: \(pointsRemaining)")
                        }
                        HStack {
                            Text("Karma Spent: \(karmaSpent)")
                            Spacer()
                            Text("Karma Remaining: \(character.karma)")
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Section {
                        HStack {
                            Spacer()
                            if onPrevious != nil {
                                Button("Previous") {
                                    onPrevious?()
                                }
                                .buttonStyle(.bordered)
                            }
                            Button("Reset") {
                                resetAttributes()
                            }
                            .buttonStyle(.bordered)
                            Button("Next") {
                                onComplete()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(totalPointsAllocated < minPointsRequired || karmaSpent > character.karma)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .navigationTitle("Allocate Attributes")
        .onAppear {
            print("AttributesAllocationView onAppear: metatype=\(character.metatype), priority=\(String(describing: character.priority?.attributes)), karma=\(character.karma)")
            if character.priority?.attributes == nil {
                errorMessage = "Please select an attributes priority before allocating points."
            } else if character.metatype.isEmpty {
                errorMessage = "No metatype selected. Please return to Metatype Selection."
            } else if let metatype = dataManager.metatypes.first(where: { $0.name == character.metatype }) {
                initializeAttributesIfNeeded(metatype: metatype)
                errorMessage = nil
            } else {
                errorMessage = "Metatype data not found for \(character.metatype). Please ensure metatype is valid."
            }
        }
    }
    
    private func attributeRow(attribute: String, metatype: Metatype) -> some View {
        HStack {
            Text(attribute)
            Spacer()
            Text("\(character.attributes[attribute] ?? 1)")
            Button("-") {
                if let currentValue = character.attributes[attribute], currentValue > attributeMin(attribute: attribute, metatype: metatype) {
                    character.attributes[attribute] = currentValue - 1
                    if let karmaPoints = karmaPurchasedAttributes[attribute], karmaPoints > 0 {
                        karmaPurchasedAttributes[attribute] = karmaPoints - 1
                        character.karma += 5
                    }
                }
            }
            .disabled(character.attributes[attribute] ?? 1 <= attributeMin(attribute: attribute, metatype: metatype))
            Button("+") {
                if let currentValue = character.attributes[attribute], currentValue < attributeMax(attribute: attribute, metatype: metatype), pointsRemaining > 0 {
                    character.attributes[attribute] = currentValue + 1
                }
            }
            .disabled(character.attributes[attribute] ?? 1 >= attributeMax(attribute: attribute, metatype: metatype) || pointsRemaining <= 0)
            Button("+K") {
                if let currentValue = character.attributes[attribute], currentValue < attributeMax(attribute: attribute, metatype: metatype), character.karma >= 5 {
                    character.attributes[attribute] = currentValue + 1
                    character.karma -= 5
                    karmaPurchasedAttributes[attribute] = (karmaPurchasedAttributes[attribute] ?? 0) + 1
                }
            }
            .disabled(character.attributes[attribute] ?? 1 >= attributeMax(attribute: attribute, metatype: metatype) || character.karma < 5)
        }
    }
    
    private func attributeMin(attribute: String, metatype: Metatype) -> Int {
        switch attribute {
        case "Body": return Int(metatype.bodmin) ?? 1
        case "Agility": return Int(metatype.agimin) ?? 1
        case "Reaction": return Int(metatype.reamin) ?? 1
        case "Strength": return Int(metatype.strmin) ?? 1
        case "Charisma": return Int(metatype.chamin) ?? 1
        case "Intuition": return Int(metatype.intmin) ?? 1
        case "Logic": return Int(metatype.logmin) ?? 1
        case "Willpower": return Int(metatype.wilmin) ?? 1
        case "Edge": return Int(metatype.edgmin) ?? 1
        default: return 1
        }
    }
    
    private func attributeMax(attribute: String, metatype: Metatype) -> Int {
        switch attribute {
        case "Body": return Int(metatype.bodmax) ?? 6
        case "Agility": return Int(metatype.agimax) ?? 6
        case "Reaction": return Int(metatype.reamax) ?? 6
        case "Strength": return Int(metatype.strmax) ?? 6
        case "Charisma": return Int(metatype.chamax) ?? 6
        case "Intuition": return Int(metatype.intmax) ?? 6
        case "Logic": return Int(metatype.logmax) ?? 6
        case "Willpower": return Int(metatype.wilmax) ?? 6
        case "Edge": return Int(metatype.edgmax) ?? 6
        default: return 6
        }
    }
    
    private func initializeAttributesIfNeeded(metatype: Metatype) {
        let attributes = ["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"]
        for attribute in attributes {
            if character.attributes[attribute] == nil {
                character.attributes[attribute] = attributeMin(attribute: attribute, metatype: metatype)
            }
        }
        karmaPurchasedAttributes = [:]
        print("Initialized attributes: \(character.attributes), karmaPurchased: \(karmaPurchasedAttributes)")
    }
    
    private func resetAttributes() {
        if let metatype = dataManager.metatypes.first(where: { $0.name == character.metatype }) {
            let attributes = ["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"]
            character.attributes = [:]
            for attribute in attributes {
                character.attributes[attribute] = attributeMin(attribute: attribute, metatype: metatype)
            }
            let karmaRefund = karmaSpent
            character.karma += karmaRefund
            karmaPurchasedAttributes = [:]
            errorMessage = nil
            print("Attributes reset: attributes=\(character.attributes), karmaRefund=\(karmaRefund), karma=\(character.karma), karmaPurchased=\(karmaPurchasedAttributes)")
        } else {
            errorMessage = "Cannot reset attributes: metatype data not found."
        }
    }
}

struct AttributesAllocationView_Previews: PreviewProvider {
    static var previews: some View {
        AttributesAllocationView(
            character: .constant(Character(
                name: "",
                metatype: "Troll",
                priority: Character.PrioritySelection(metatype: "D", attributes: "A", skills: "C", magic: "E", resources: "B"),
                attributes: ["Body": 5, "Agility": 1, "Reaction": 1, "Strength": 5, "Charisma": 1, "Intuition": 1, "Logic": 1, "Willpower": 1, "Edge": 1],
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
            )),
            onComplete: {},
            onPrevious: {}
        )
        .environmentObject({
            let dm = DataManager()
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
            dm.priorityData = PriorityData(
                metatype: [
                    "A": [MetatypeOption(name: "Human", specialAttributePoints: 9, karma: 0)],
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
            return dm
        }())
    }
}
