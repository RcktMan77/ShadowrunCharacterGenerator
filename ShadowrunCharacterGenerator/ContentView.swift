//
//  ContentView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject var dataManager = DataManager.shared
    @State private var character = Character(
        name: "",
        metatype: "",
        priority: nil,
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
    )
    @State private var errorMessage: String?
    @State private var showingSavePanel = false
    @State private var showingExportAlert = false
    
    var body: some View {
        NavigationSplitView {
            List {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                ForEach(dataManager.errors.sorted(by: { $0.key < $1.key }), id: \.key) { key, message in
                    Text("\(key): \(message)")
                        .foregroundColor(.red)
                        .padding(.vertical, 2)
                }
                
                NavigationLink("Create Character", destination: CharacterCreationView(onComplete: { createdCharacter in
                    character = createdCharacter
                }))
                NavigationLink("Character Sheet", destination: CharacterSheetView(character: character))
                NavigationLink("Sourcebooks", destination: SourcebookSelectionView(character: $character, onComplete: {
                    dataManager.saveSelectedSourcebooks()
                }))
                NavigationLink("Qualities", destination: QualitiesSelectionView(character: $character, onComplete: {}))
                NavigationLink("Gear", destination: GearSelectionView(character: $character))
                NavigationLink("Contacts", destination: ContactsSelectionView(character: $character, onComplete: {}))
                NavigationLink("Progression", destination: ProgressionView(character: $character))
                NavigationLink("Martial Arts", destination: MartialArtsView(character: $character))
            }
            .listStyle(.sidebar)
            .navigationTitle("Shadowrun Character Generator")
        } detail: {
            Text("Select an option from the sidebar")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .environmentObject(dataManager)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingSavePanel = true
                }) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save Character")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingExportAlert = true
                }) {
                    Image(systemName: "doc.text")
                    Text("Export PDF")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: resetCharacter) {
                    Image(systemName: "plus")
                    Text("New Character")
                }
            }
        }
        .sheet(isPresented: $showingSavePanel) {
            SavePanel { url in
                if let url = url {
                    saveCharacter(to: url)
                }
                showingSavePanel = false
            }
        }
        .alert("Export PDF", isPresented: $showingExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("PDF export is not yet implemented.")
        }
        .onAppear {
            let criticalResources = ["books", "priorities"]
            let criticalErrors = dataManager.errors.filter { criticalResources.contains($0.key) }
            if !criticalErrors.isEmpty {
                errorMessage = "Failed to load essential data: \(criticalErrors.map { $0.key }.joined(separator: ", "))."
            }
        }
    }
    
    private func saveCharacter(to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(character)
            try data.write(to: url)
        } catch {
            errorMessage = "Failed to save character: \(error.localizedDescription)"
        }
    }
    
    private func resetCharacter() {
        character = Character(
            name: "",
            metatype: "",
            priority: nil,
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
        )
    }
}

struct SavePanel: NSViewControllerRepresentable {
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
        var parent: SavePanel
        
        init(_ parent: SavePanel) {
            self.parent = parent
            super.init()
            openPanel()
        }
        
        func openPanel() {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = "character.json"
            panel.canCreateDirectories = true
            
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager.shared)
    }
}
