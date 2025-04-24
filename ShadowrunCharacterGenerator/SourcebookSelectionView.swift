//
//  SourcebookSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI
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
                DocumentPicker { url in
                    if let url = url, let code = selectedBookCode {
                        dataManager.selectedSourcebooks[code] = url
                    }
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

struct DocumentPicker: UIViewControllerRepresentable {
    let onSelect: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onSelect(urls.first)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onSelect(nil)
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
