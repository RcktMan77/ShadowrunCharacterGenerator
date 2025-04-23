//
//  SkillsAllocationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct SkillsAllocationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    @State private var skillPointsRemaining: Int
    
    init(character: Binding<Character>, onComplete: @escaping () -> Void) {
        self._character = character
        self.onComplete = onComplete
        self._skillPointsRemaining = State(initialValue: 0) // Default value
    }
    
    var body: some View {
        Form {
            ForEach(dataManager.skills, id: \.name) { skill in
                HStack {
                    Text(NSLocalizedString(skill.name, comment: "Skill name"))
                    Stepper(value: Binding(
                        get: { character.skills[skill.name] ?? 0 },
                        set: { newValue in
                            let delta = newValue - (character.skills[skill.name] ?? 0)
                            if skillPointsRemaining >= delta && newValue >= 0 && newValue <= 12 {
                                character.skills[skill.name] = newValue
                                skillPointsRemaining -= delta
                            }
                        }
                    ), in: 0...12) {
                        Text("\(character.skills[skill.name] ?? 0)")
                    }
                }
            }
            Text("Skill Points Remaining: \(skillPointsRemaining)")
            Button("Next") {
                onComplete()
            }
            .disabled(skillPointsRemaining > 0)
        }
        .onAppear {
            // Set skill points based on priority (example assumes priority stored elsewhere)
            let skillPriority = dataManager.priorityData.skills["A"] ?? SkillPriority(skillPoints: 0, skillGroupPoints: 0)
            skillPointsRemaining = skillPriority.skillPoints
        }
        .navigationTitle("Allocate Skills")
    }
}
