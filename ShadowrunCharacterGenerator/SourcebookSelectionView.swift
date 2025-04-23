//
//  SourcebookSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SourcebookSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDocumentPicker = false
    @State private var selectedBookCode: String?
    
    var body: some View {
        List {
            ForEach(dataManager.books, id: \.code) { book in
                HStack {
                    Text(book.name)
                    if let url = dataManager.selectedSourcebooks[book.code] {
                        Text(url.lastPathComponent)
                    } else {
                        Button("Select PDF") {
                            selectedBookCode = book.code
                            showingDocumentPicker = true
                        }
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
        .navigationTitle("Select Sourcebooks")
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
