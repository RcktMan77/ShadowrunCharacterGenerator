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
    @Binding var selectedMetatypePriority: String
    let onComplete: () -> Void
    let onPrevious: () -> Void
    @State private var selectedMetatype: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Select Metatype")) {
                Picker("Metatype", selection: $selectedMetatype) {
                    Text("Select a metatype").tag("")
                    ForEach(dataManager.metatypes, id: \.name) { metatype in
                        Text(metatype.name).tag(metatype.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if let metatype = dataManager.metatypes.first(where: { $0.name == selectedMetatype }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Karma Cost: \(metatype.karma)")
                        Text("Attributes:")
                        Text("Body: \(metatype.bodmin)-\(metatype.bodmax)")
                        Text("Agility: \(metatype.agimin)-\(metatype.agimax)")
                        Text("Reaction: \(metatype.reamin)-\(metatype.reamax)")
                        Text("Strength: \(metatype.strmin)-\(metatype.strmax)")
                        Text("Charisma: \(metatype.chamin)-\(metatype.chamax)")
                        Text("Intuition: \(metatype.intmin)-\(metatype.intmax)")
                        Text("Logic: \(metatype.logmin)-\(metatype.logmax)")
                        Text("Willpower: \(metatype.wilmin)-\(metatype.wilmax)")
                        Text("Edge: \(metatype.edgmin)-\(metatype.edgmax)")
                        if !metatype.metavariants.isEmpty {
                            Text("Metavariants: \(metatype.metavariants?.map { $0.name }.joined(separator: ", ") ?? "None")")
                        }
                    }
                    .padding(.top, 8)
                }
            }
            
            HStack {
                Button("Previous") {
                    onPrevious()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Next") {
                    character.metatype = selectedMetatype
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedMetatype.isEmpty)
            }
        }
        .navigationTitle("Select Metatype")
        .onAppear {
            if let firstMetatype = dataManager.metatypes.first {
                selectedMetatype = firstMetatype.name
            }
        }
    }
}

struct MetatypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MetatypeSelectionView(
            character: .constant(Character(
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
            )),
            selectedMetatypePriority: .constant("A"),
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
                )
            ]
            return dm
        }())
    }
}
