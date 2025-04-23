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
    let onComplete: () -> Void
    @State private var selectedMetatype: String?
    
    var body: some View {
        Form {
            Picker("Metatype", selection: $selectedMetatype) {
                Text("Select Metatype").tag(String?.none)
                ForEach(dataManager.priorityData.metatype["A"] ?? [], id: \.name) { metatype in
                    Text(metatype.name).tag(String?.some(metatype.name))
                }
            }
            
            Button("Next") {
                if let metatype = selectedMetatype {
                    character.metatype = metatype
                    onComplete()
                }
            }
            .disabled(selectedMetatype == nil)
        }
        .navigationTitle("Select Metatype")
    }
}
