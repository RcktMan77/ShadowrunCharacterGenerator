//
//  MetatypeSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct MetatypeSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @Binding var selectedMetatype: String
    let onComplete: () -> Void
    @State private var errorMessage: String?

    private let attributeDescriptions: [String: String] = [
        "Body": "Increases physical durability and resistance to damage.",
        "Agility": "Improves dexterity, accuracy in ranged and melee combat.",
        "Reaction": "Enhances reflexes, dodging, and initiative.",
        "Strength": "Boosts physical power and melee damage.",
        "Willpower": "Strengthens mental resilience and resistance to stun damage.",
        "Logic": "Aids problem-solving, hacking, and technical skills.",
        "Intuition": "Improves perception, intuition-based skills, and initiative.",
        "Charisma": "Enhances social interactions, leadership, and negotiation.",
        "Edge": "Grants luck points for special actions and critical moments."
    ]

    private let attributesList: [String] = [
        "Body", "Agility", "Reaction", "Strength", "Willpower", "Logic", "Intuition", "Charisma", "Edge"
    ]

    var body: some View {
        VStack(spacing: 20) { // Increased vertical spacing
            Form {
                errorSection
                if errorMessage == nil && !dataManager.metatypes.isEmpty {
                    metatypeSelectionSection
                    if !selectedMetatype.isEmpty, let metatype = dataManager.metatypes.first(where: { $0.name == selectedMetatype }) {
                        metatypeDetailsSection(for: metatype)
                    }
                    navigationSection
                }
            }
            .frame(maxWidth: 600) // Constrain form width
        }
        .frame(maxWidth: .infinity, alignment: .center) // Center content
        .navigationTitle("Select Metatype")
        .onAppear {
            if dataManager.metatypes.isEmpty || dataManager.errors["metatypes"] != nil {
                selectedMetatype = ""
                errorMessage = dataManager.errors["metatypes"] ?? "No metatype data available."
            } else if selectedMetatype.isEmpty, let firstMetatype = dataManager.metatypes.first {
                selectedMetatype = firstMetatype.name
            }
        }
        .onChange(of: selectedMetatype, initial: false) { _, newValue in
            character.metatype = newValue
        }
    }

    private var errorSection: some View {
        Group {
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding(.vertical, 10) // Additional padding for error section
    }

    private var metatypeSelectionSection: some View {
        Section {
            Picker("Metatype", selection: $selectedMetatype) {
                Text("Select").tag("")
                ForEach(dataManager.metatypes, id: \.id) { metatype in
                    Text(metatype.name).tag(metatype.name)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 200) // Constrain width
        }
        .padding(.vertical, 10) // Additional padding for section
    }

    private func metatypeDetailsSection(for metatype: Metatype) -> some View {
        Section(header: Text("Metatype Details")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Attributes:")
                    .font(.headline)
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 8) {
                    ForEach(attributesList, id: \.self) { attribute in
                        GridRow {
                            Text(attribute)
                                .frame(minWidth: 80, alignment: .leading)
                            Text(attributeRange(for: attribute, metatype: metatype))
                                .frame(minWidth: 50, alignment: .leading)
                            Text(attributeDescriptions[attribute] ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(alignment: .leading)
                        }
                    }
                }
                .padding(.all, 10)
                .background(Color.gray.opacity(0.1)) // Subtle background contrast
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Border
                )
                if let variants = metatype.metavariants, !variants.isEmpty {
                    Text("Metavariants: \(variants.map { $0.name }.joined(separator: ", "))")
                }
            }
        }
        .padding(.vertical, 10) // Additional padding for section
    }

    private func attributeRange(for attribute: String, metatype: Metatype) -> String {
        switch attribute {
        case "Body": return "\(metatype.bodmin)-\(metatype.bodmax)"
        case "Agility": return "\(metatype.agimin)-\(metatype.agimax)"
        case "Reaction": return "\(metatype.reamin)-\(metatype.reamax)"
        case "Strength": return "\(metatype.strmin)-\(metatype.strmax)"
        case "Willpower": return "\(metatype.wilmin)-\(metatype.wilmax)"
        case "Logic": return "\(metatype.logmin)-\(metatype.logmax)"
        case "Intuition": return "\(metatype.intmin)-\(metatype.intmax)"
        case "Charisma": return "\(metatype.chamin)-\(metatype.chamax)"
        case "Edge": return "\(metatype.edgmin)-\(metatype.edgmax)"
        default: return ""
        }
    }

    private var navigationSection: some View {
        Section {
            HStack {
                Spacer()
                Button("Next") {
                    if !selectedMetatype.isEmpty {
                        onComplete()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedMetatype.isEmpty)
            }
            .padding()
        }
        .padding(.vertical, 10) // Additional padding for section
    }
}

struct MetatypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MetatypeSelectionView(
            character: .constant(Character(
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
            )),
            selectedMetatype: .constant(""),
            onComplete: {}
        )
        .environmentObject({
            let dm = DataManager()
            dm.metatypes = [
                Metatype(
                    id: "1",
                    name: "Human",
                    karma: "0", // Standard SR5: No karma cost
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
                    karma: "0", // Standard SR5: No karma cost
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
                    "A": [MetatypeOption(name: "Human", specialAttributePoints: 9, karma: 0), MetatypeOption(name: "Troll", specialAttributePoints: 5, karma: 0)],
                    "B": [MetatypeOption(name: "Dwarf", specialAttributePoints: 7, karma: 0)],
                    "C": [MetatypeOption(name: "Ork", specialAttributePoints: 7, karma: 0)],
                    "D": [MetatypeOption(name: "Troll", specialAttributePoints: 5, karma: 0)],
                    "E": [MetatypeOption(name: "Human", specialAttributePoints: 1, karma: 0)]
                ],
                attributes: [:],
                skills: [:],
                magic: [:],
                resources: [:]
            )
            return dm
        }())
    }
}
