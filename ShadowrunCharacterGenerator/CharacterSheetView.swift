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
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    contentView
                }
            }
            .navigationTitle("Character Sheet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .sheet(isPresented: $showingPDFViewer) {
                if let url = selectedPDFURL {
                    PDFViewer(url: url)
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var contentView: some View {
        Form {
            // Error Messages for Data Types
            errorSection

            // Personal Info
            Section(header: Text("Personal Info")) {
                LabeledContent("Name", value: character.name.isEmpty ? "N/A" : character.name)
                LabeledContent("Metatype", value: character.metatype.isEmpty ? "N/A" : character.metatype)
            }

            // Attributes
            Section(header: Text("Attributes")) {
                attributesView
            }

            // Skills
            Section(header: Text("Skills")) {
                skillsView
            }

            // Resources
            Section(header: Text("Resources")) {
                LabeledContent("Karma", value: "\(character.karma)")
                LabeledContent("Nuyen", value: "\(character.nuyen)")
            }

            // Gear
            Section(header: Text("Gear")) {
                gearView
            }

            // Qualities
            Section(header: Text("Qualities")) {
                qualitiesView
            }

            // Contacts
            Section(header: Text("Contacts")) {
                contactsView
            }

            // Magic
            Section(header: Text("Magic")) {
                magicView
            }

            // Technomancer
            Section(header: Text("Technomancer")) {
                technomancerView
            }

            // Licenses
            Section(header: Text("Licenses")) {
                licensesView
            }

            // Lifestyle
            Section(header: Text("Lifestyle")) {
                LabeledContent("Lifestyle", value: character.lifestyle ?? "None")
            }

            // Martial Arts
            Section(header: Text("Martial Arts")) {
                martialArtsView
            }

            // Sourcebooks
            Section(header: Text("Sourcebooks")) {
                sourcebooksView
            }
        }
    }

    private var errorSection: some View {
        Group {
            let dataTypes = [
                ("skills", "skills.json"),
                ("gear", "gear.json"),
                ("qualities", "qualities.json"),
                ("contacts", "contacts.json"),
                ("spells", "spells.json"),
                ("complexforms", "complexforms.json"),
                ("powers", "powers.json"),
                ("mentors", "mentors.json"),
                ("traditions", "traditions.json"),
                ("metamagic", "metamagic.json"),
                ("echoes", "echoes.json"),
                ("licenses", "licenses.json"),
                ("lifestyles", "lifestyles.json"),
                ("martialarts", "martialarts.json"),
                ("books", "books.json")
            ]
            ForEach(dataTypes, id: \.0) { (key, file) in
                if let error = dataManager.errors[key] {
                    Text("Error: \(error). Please ensure \(file) is present and correctly formatted.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            if dataManager.books.isEmpty {
                Text("Error: No books data available. Please ensure books.json contains valid book entries.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    private var attributesView: some View {
        Group {
            if character.attributes.isEmpty {
                Text("No attributes assigned")
            } else {
                let sortedKeys = character.attributes.keys.sorted()
                ForEach(sortedKeys, id: \.self) { key in
                    if let value = character.attributes[key] {
                        LabeledContent(key, value: "\(value)")
                    }
                }
            }
        }
    }

    private var skillsView: some View {
        Group {
            if character.skills.isEmpty {
                Text("No skills assigned")
            } else {
                let sortedKeys = character.skills.keys.sorted()
                ForEach(sortedKeys, id: \.self) { key in
                    if let value = character.skills[key] {
                        LabeledContent(key, value: "\(value)")
                    }
                }
            }
        }
    }

    private var gearView: some View {
        Group {
            if character.gear.isEmpty {
                Text("No gear assigned")
            } else {
                let sortedKeys = character.gear.keys.sorted()
                ForEach(sortedKeys, id: \.self) { key in
                    if let value = character.gear[key] {
                        LabeledContent(key, value: "\(value)")
                    }
                }
            }
        }
    }

    private var qualitiesView: some View {
        Group {
            if character.qualities.isEmpty {
                Text("No qualities assigned")
            } else {
                let sortedKeys = character.qualities.keys.sorted()
                ForEach(sortedKeys, id: \.self) { key in
                    if let value = character.qualities[key] {
                        LabeledContent(key, value: "\(value)")
                    }
                }
            }
        }
    }

    private var contactsView: some View {
        Group {
            if character.contacts.isEmpty {
                Text("No contacts assigned")
            } else {
                let sortedKeys = character.contacts.keys.sorted()
                ForEach(sortedKeys, id: \.self) { key in
                    if let value = character.contacts[key] {
                        LabeledContent(key, value: "Loyalty: \(value.loyalty), Connection: \(value.connection)")
                    }
                }
            }
        }
    }

    private var magicView: some View {
        Group {
            LabeledContent("Spells", value: character.spells.isEmpty ? "None" : character.spells.joined(separator: ", "))
            LabeledContent("Complex Forms", value: character.complexForms.isEmpty ? "None" : character.complexForms.joined(separator: ", "))
            LabeledContent("Powers", value: character.powers.isEmpty ? "None" : character.powers.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
            LabeledContent("Mentor", value: character.mentor ?? "None")
            LabeledContent("Tradition", value: character.tradition ?? "None")
            LabeledContent("Metamagic", value: character.metamagic.isEmpty ? "None" : character.metamagic.joined(separator: ", "))
        }
    }

    private var technomancerView: some View {
        Group {
            LabeledContent("Echoes", value: character.echoes.isEmpty ? "None" : character.echoes.joined(separator: ", "))
        }
    }

    private var licensesView: some View {
        Group {
            if character.licenses.isEmpty {
                Text("No licenses assigned")
            } else {
                let sortedKeys = character.licenses.keys.sorted()
                ForEach(sortedKeys, id: \.self) { key in
                    if let value = character.licenses[key] {
                        LabeledContent(key, value: "\(value)")
                    }
                }
            }
        }
    }

    private var martialArtsView: some View {
        Group {
            LabeledContent("Martial Arts", value: character.martialArts.isEmpty ? "None" : character.martialArts.joined(separator: ", "))
        }
    }

    private var sourcebooksView: some View {
        Group {
            if character.sourcebooks.isEmpty {
                Text("No sourcebooks selected")
            } else {
                let sortedBooks = character.sourcebooks.sorted()
                ForEach(sortedBooks, id: \.self) { code in
                    let bookName = dataManager.books.first(where: { $0.code == code })?.name ?? code
                    HStack {
                        LabeledContent(bookName, value: dataManager.selectedSourcebooks[code]?.lastPathComponent ?? "No PDF")
                        Spacer()
                        Button("View PDF") {
                            if let pdfURL = dataManager.selectedSourcebooks[code] {
                                if FileManager.default.fileExists(atPath: pdfURL.path) {
                                    selectedPDFURL = pdfURL
                                    showingPDFViewer = true
                                } else {
                                    errorMessage = "Error: PDF file for \(bookName) is inaccessible. Please verify the file path in selected sourcebooks."
                                }
                            } else {
                                errorMessage = "Error: No PDF assigned for \(bookName). Please assign a valid PDF in sourcebook settings."
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(dataManager.selectedSourcebooks[code] == nil)
                    }
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
            priority: nil,
            attributes: ["Body": 3, "Agility": 5],
            skills: ["Firearms": 4, "Stealth": 3],
            specializations: [:],
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
                Book(id: "1", name: "Shadowrun Core Rulebook", code: "core", matches: nil),
                Book(id: "2", name: "Street Grimoire", code: "sg", matches: nil)
            ]
            dm.selectedSourcebooks = ["core": URL(fileURLWithPath: "/path/to/core.pdf")]
            return dm
        }())
    }
}
