//
//  RangesView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct RangesView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("Weapon Ranges", comment: "Section header"))) {
                if dataManager.ranges.isEmpty {
                    Text(NSLocalizedString("No ranges available", comment: "Empty message"))
                } else {
                    ForEach(dataManager.ranges, id: \.name) { range in
                        VStack(alignment: .leading) {
                            Text(NSLocalizedString(range.name, comment: "Range name"))
                                .font(.headline)
                            HStack {
                                Text(NSLocalizedString("Short", comment: "Range label")) + Text(": \(range.short) m")
                                Spacer()
                                Text(NSLocalizedString("Medium", comment: "Range label")) + Text(": \(range.medium) m")
                            }
                            HStack {
                                Text(NSLocalizedString("Long", comment: "Range label")) + Text(": \(range.long) m")
                                Spacer()
                                Text(NSLocalizedString("Extreme", comment: "Range label")) + Text(": \(range.extreme) m")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("Weapon Ranges", comment: "Title"))
    }
}

struct RangesView_Previews: PreviewProvider {
    static var previews: some View {
        RangesView()
            .environmentObject(DataManager())
    }
}
