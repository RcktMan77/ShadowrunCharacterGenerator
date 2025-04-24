//
//  SourcebookSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SourcebookSelectionView: View {
    @Binding var character: Character
    @EnvironmentObject var dataManager: DataManager
    let onComplete: () -> Void
    
    @State private var selectedBooks: [String] = []
    @State private var showingDocumentPicker = false
    @State private var selectedBookCode: String?
    
    var body: some View {
        VStack {
            List {
                ForEach(dataManager.books, id: \.code) { book in
                    HStack {
                        // Toggle for selecting the book
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
                        
                        // PDF selection
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
            }
            .sheet(isPresented: $showingDocumentPicker) {
                OpenPanel { url in
                    if let url = url, let code = selectedBookCode {
                        dataManager.selectedSourcebooks[code] = url
                    }
                    showingDocumentPicker = false
                }
            }
            
            Button("Confirm") {
                // Update character.sourcebooks with selected book codes
                character.sourcebooks = selectedBooks
                onComplete() // Trigger completion action
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(selectedBooks.isEmpty) // Require at least one selection
        }
        .navigationTitle("Select Sourcebooks")
        .onAppear {
            // Initialize with character's existing sourcebooks
            selectedBooks = character.sourcebooks
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
            onComplete: {}
        )
        .environmentObject(DataManager())
    }
}
