//
//  QualitiesSelectionView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct QualitiesSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    @State private var selectedQualities: [String: Int] = [:]
    @State private var karmaBalance: Int = 25 // Max 25 Karma for positive/negative
    
    var body: some View {
        Form {
            ForEach(dataManager.qualities, id: \.name) { quality in
                HStack {
                    Text(quality.name)
                    Text("\(quality.karmaCost) Karma")
                    Button(quality.type == "Positive" ? "Add" : "Take") {
                        let cost = quality.type == "Positive" ? quality.karmaCost : -quality.karmaCost
                        if abs(karmaBalance + cost) <= 25 {
                            selectedQualities[quality.name] = quality.karmaCost
                            karmaBalance += cost
                        }
                    }
                }
            }
            Text("Karma Balance: \(karmaBalance)")
            Button("Next") {
                character.qualities = selectedQualities
                character.karma += karmaBalance // Adjust Karma based on negative qualities
                onComplete()
            }
        }
        .navigationTitle("Select Qualities")
    }
}
