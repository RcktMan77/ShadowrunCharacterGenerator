//
//  AttributesView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//
import SwiftUI

struct AttributesAllocationView: View {
    @Binding var character: Character
    let onComplete: () -> Void
    @State private var pointsRemaining: Int = 12 // Example; adjust based on priority
    
    var body: some View {
        Form {
            ForEach(["Body", "Agility", "Reaction", "Strength", "Charisma", "Intuition", "Logic", "Willpower", "Edge"], id: \.self) { attr in
                HStack {
                    Text(attr)
                    Stepper(value: Binding(
                        get: { character.attributes[attr] ?? 1 },
                        set: { newValue in
                            let delta = newValue - (character.attributes[attr] ?? 1)
                            if pointsRemaining >= delta && newValue >= 1 && newValue <= 12 {
                                character.attributes[attr] = newValue
                                pointsRemaining -= delta
                            }
                        }
                    ), in: 1...12) {
                        Text("\(character.attributes[attr] ?? 1)")
                    }
                }
            }
            Text("Points Remaining: \(pointsRemaining)")
            Button("Next") {
                onComplete()
            }
            .disabled(pointsRemaining > 0)
        }
        .navigationTitle("Allocate Attributes")
    }
}
