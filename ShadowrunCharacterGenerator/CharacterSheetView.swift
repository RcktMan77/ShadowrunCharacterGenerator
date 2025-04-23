//
//  CharacterSheetView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI
import PDFKit

struct CharacterSheetView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    @State private var showingPDFViewer = false
    @State private var selectedPDFURL: URL?
    
    var body: some View {
        VStack {
            Text("Name: \(character.name)")
            Text("Metatype: \(character.metatype)")
            Text("Karma: \(character.karma)")
            Text("Nuyen: \(character.nuyen)")
            
            AttributesView(character: $character)
            SkillsView(character: $character)
            
            Button("Add Karma (10)") {
                character.karma += 10
            }
            Button("Add Nuyen (1000)") {
                character.nuyen += 1000
            }
            
            Button("Open Core Rulebook") {
                if let pdfURL = dataManager.selectedSourcebooks["SR5: Core"] {
                    selectedPDFURL = pdfURL
                    showingPDFViewer = true
                } else {
                    print("No PDF selected for SR5: Core")
                }
            }
            .disabled(dataManager.selectedSourcebooks["SR5: Core"] == nil)
        }
        .sheet(isPresented: $showingPDFViewer) {
            if let url = selectedPDFURL {
                PDFViewer(url: url)
            }
        }
    }
}

struct PDFViewer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        pdfView.document = PDFDocument(url: url)
        if didStartAccessing {
            url.stopAccessingSecurityScopedResource()
        }
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
