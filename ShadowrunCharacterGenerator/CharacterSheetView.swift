//
//  CharacterSheetView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI
import PDFKit
import AppKit

struct CharacterSheetView: View {
    let character: Character
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var showingPDFViewer = false
    @State private var selectedPDFURL: URL?
    
    var body: some View {
        NavigationView {
            Form {
                // Personal Info
                Section(header: Text("Personal Info")) {
                    LabeledContent("Name", value: character.name.isEmpty ? "N/A" : character.name)
                    LabeledContent("Metatype", value: character.metatype.isEmpty ? "N/A" : character.metatype)
                }
                
                // Attributes
                Section(header: Text("Attributes")) {
                    if character.attributes.isEmpty {
                        Text("No attributes assigned")
                    } else {
                        ForEach(character.attributes.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            LabeledContent(key, value: "\(value)")
                        }
                    }
                }
                
                // Skills
                Section(header: Text("Skills")) {
                    if character.skills.isEmpty {
                        Text("No skills assigned")
                    } else {
                        ForEach(character.skills.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            LabeledContent(key, value: "\(value)")
                        }
                    }
                }
                
                // Resources
                Section(header: Text("Resources")) {
                    LabeledContent("Karma", value: "\(character.karma)")
                    LabeledContent("Nuyen", value: "\(character.nuyen)")
                }
                
                // Gear
                Section(header: Text("Gear")) {
                    if character.gear.isEmpty {
                        Text("No gear assigned")
                    } else {
                        ForEach(character.gear.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            LabeledContent(key, value: "\(value)")
                        }
                    }
                }
                
                // Qualities
                Section(header: Text("Qualities")) {
                    if character.qualities.isEmpty {
                        Text("No qualities assigned")
                    } else {
                        ForEach(character.qualities.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            LabeledContent(key, value: "\(value)")
                        }
                    }
                }
                
                // Contacts
                Section(header: Text("Contacts")) {
                    if character.contacts.isEmpty {
                        Text("No contacts assigned")
                    } else {
                        ForEach(character.contacts.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            LabeledContent(key, value: "Loyalty: \(value.loyalty), Connection: \(value.connection)")
                        }
                    }
                }
                
                // Magic
                Section(header: Text("Magic")) {
                    LabeledContent("Spells", value: character.spells.isEmpty ? "None" : character.spells.joined(separator: ", "))
                    LabeledContent("Complex Forms", value: character.complexForms.isEmpty ? "None" : character.complexForms.joined(separator: ", "))
                    LabeledContent("Powers", value: character.powers.isEmpty ? "None" : character.powers.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
                    LabeledContent("Mentor", value: character.mentor ?? "None")
                    LabeledContent("Tradition", value: character.tradition ?? "None")
                    LabeledContent("Metamagic", value: character.metamagic.isEmpty ? "None" : character.metamagic.joined(separator: ", "))
                }
                
                // Technomancer
                Section(header: Text("Technomancer")) {
                    LabeledContent("Echoes", value: character.echoes.isEmpty ? "None" : character.echoes.joined(separator: ", "))
                }
                
                // Licenses
                Section(header: Text("Licenses")) {
                    if character.licenses.isEmpty {
                        Text("No licenses assigned")
                    } else {
                        ForEach(character.licenses.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            LabeledContent(key, value: "\(value)")
                        }
                    }
                }
                
                // Lifestyle
                Section(header: Text("Lifestyle")) {
                    LabeledContent("Lifestyle", value: character.lifestyle ?? "None")
                }
                
                // Martial Arts
                Section(header: Text("Martial Arts")) {
                    LabeledContent("Martial Arts", value: character.martialArts.isEmpty ? "None" : character.martialArts.joined(separator: ", "))
                }
                
                // Sourcebooks
                Section(header: Text("Sourcebooks")) {
                    if character.sourcebooks.isEmpty {
                        Text("No sourcebooks selected")
                    } else {
                        ForEach(character.sourcebooks.sorted(), id: \.self) { code in
                            let bookName = dataManager.books.first(where: { $0.code == code })?.name ?? code
                            HStack {
                                LabeledContent(bookName, value: dataManager.selectedSourcebooks[code]?.lastPathComponent ?? "No PDF")
                                Spacer()
                                Button("View PDF") {
                                    if let pdfURL = dataManager.selectedSourcebooks[code] {
                                        selectedPDFURL = pdfURL
                                        showingPDFViewer = true
                                    }
                                }
                                .disabled(dataManager.selectedSourcebooks[code] == nil)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Character Sheet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPDFViewer) {
                if let url = selectedPDFURL {
                    PDFViewer(url: url)
                }
            }
        }
    }
}

struct PDFViewer: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {}
}

struct CharacterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterSheetView(character: Character(
            name: "John Doe",
            metatype: "Elf",
            attributes: ["Body": 3, "Agility": 5],
            skills: ["Firearms": 4, "Stealth": 3],
            karma: 10,
            nuyen: 5000,
            gear: ["Pistol": 1],
            qualities: ["Low-Light Vision": 1],
            contacts: ["Fixer": Contact(name: "Fixer", connection: 2, loyalty: 3)],
            spells: ["Fireball"],
            complexForms: [],
            powers: [:],
            mentor: "Dragon",
            tradition: "Hermetic",
            metamagic: ["Centering"],
            echoes: [],
            licenses: ["Firearm": 1],
            lifestyle: "Low",
            martialArts: ["Kung Fu"],
            sourcebooks: ["core", "sg"]
        ))
        .environmentObject({
            let dm = DataManager()
            dm.books = [
                Book(name: "Shadowrun Core Rulebook", code: "core"),
                Book(name: "Street Grimoire", code: "sg")
            ]
            dm.selectedSourcebooks = ["core": URL(fileURLWithPath: "/path/to/core.pdf")]
            return dm
        }())
    }
}
