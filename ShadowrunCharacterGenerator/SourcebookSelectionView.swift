//
//  SourcebookSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI
import AppKit

struct SourcebookSelectionView: View {
    @Binding var character: Character
    @EnvironmentObject var dataManager: DataManager
    let onComplete: () -> Void
    let onPrevious: (() -> Void)?
    @State private var selectedBooks: [String] = []
    @State private var showingDocumentPicker = false
    @State private var selectedBookCode: String?
    @State private var errorMessage: String?

    init(character: Binding<Character>, onComplete: @escaping () -> Void, onPrevious: (() -> Void)? = nil) {
        self._character = character
        self.onComplete = onComplete
        self.onPrevious = onPrevious
    }

    var body: some View {
        NavigationStack {
            Form {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                if let booksError = dataManager.errors["books"] {
                    Text(booksError)
                        .foregroundColor(.red)
                        .padding()
                }

                ForEach(dataManager.books, id: \.code) { book in
                    HStack {
                        Toggle(isOn: Binding(
                            get: { selectedBooks.contains(book.code) },
                            set: { isSelected in
                                if isSelected {
                                    selectedBooks.append(book.code)
                                } else {
                                    selectedBooks.removeAll { $0 == book.code }
                                }
                            }
                        )) {
                            Text(book.name)
                        }
                        .toggleStyle(.checkbox)

                        if let url = dataManager.selectedSourcebooks[book.code] {
                            Text(url.lastPathComponent)
                                .foregroundColor(.secondary)
                        } else {
                            Button("Select PDF") {
                                selectedBookCode = book.code
                                showingDocumentPicker = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Section {
                    HStack {
                        if onPrevious != nil {
                            Button("Previous") {
                                onPrevious?()
                            }
                            .buttonStyle(.bordered)
                        }
                        Spacer()
                        Button("Next") {
                            character.sourcebooks = selectedBooks
                            dataManager.saveSelectedSourcebooks()
                            onComplete()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedBooks.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Sourcebooks")
            .sheet(isPresented: $showingDocumentPicker) {
                OpenPanel { url in
                    if let url = url, let code = selectedBookCode {
                        dataManager.selectedSourcebooks[code] = url
                    }
                    showingDocumentPicker = false
                }
            }
            .onAppear {
                if dataManager.books.isEmpty && dataManager.errors["books"] == nil {
                    errorMessage = "No sourcebooks available."
                }
                selectedBooks = character.sourcebooks
            }
        }
    }
}

struct OpenPanel: NSViewControllerRepresentable {
    let onSelect: (URL?) -> Void

    func makeNSViewController(context: Context) -> NSViewController {
        let controller = NSViewController()
        context.coordinator.parent = self
        return controller
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: OpenPanel

        init(_ parent: OpenPanel) {
            self.parent = parent
            super.init()
            openPanel()
        }

        func openPanel() {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.pdf]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true

            panel.begin { response in
                if response == .OK, let url = panel.url {
                    self.parent.onSelect(url)
                } else {
                    self.parent.onSelect(nil)
                }
            }
        }
    }
}

struct SourcebookSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SourcebookSelectionView(
            character: .constant(Character(
                name: "",
                metatype: "",
                priority: Character.PrioritySelection(
                    metatype: "A",
                    attributes: "B",
                    skills: "C",
                    magic: "D",
                    resources: "E"
                ),
                attributes: [:],
                skills: [:],
                specializations: [:],
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
            onComplete: {},
            onPrevious: {}
        )
        .environmentObject({
            let dm = DataManager()
            dm.priorityData = PriorityData(
                metatype: [:],
                attributes: [:],
                skills: [:],
                magic: [
                    "D-Adept": MagicPriority(type: "Adept", points: 2, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil),
                    "E-Mundane": MagicPriority(type: "Mundane", points: 0, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil)
                ],
                resources: [:]
            )
            dm.books = [
                Book(id: "1", name: "Shadowrun Core Rulebook", code: "SR5", matches: nil),
                Book(id: "2", name: "Run & Gun", code: "R&G", matches: nil)
            ]
            dm.errors = [:]
            return dm
        }())
    }
}
