//
//  ActionsView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct ActionsView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("Actions", comment: "Section header"))) {
                if let actionsError = dataManager.errors["actions"] {
                    Text("Actions data error: \(actionsError)")
                        .foregroundColor(.red)
                        .padding()
                } else if dataManager.actions.isEmpty {
                    Text(NSLocalizedString("No actions available", comment: "Empty message"))
                } else {
                    ForEach(dataManager.actions.sorted(by: { $0.name < $1.name }), id: \.name) { action in
                        VStack(alignment: .leading) {
                            Text(NSLocalizedString(action.name, comment: "Action name"))
                                .font(.headline)
                            Text(NSLocalizedString("Type", comment: "Label")) + Text(": \(action.type)")
                            if let requirements = action.requirements {
                                Text(NSLocalizedString("Requirements", comment: "Label")) + Text(": \(requirements)")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("Actions", comment: "Title"))
    }
}

struct ActionsView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsView()
            .environmentObject({
                let dm = DataManager.shared
                dm.actions = [Action(name: "Sprint", type: "Complex", requirements: "None")]
                return dm
            }())
    }
}
