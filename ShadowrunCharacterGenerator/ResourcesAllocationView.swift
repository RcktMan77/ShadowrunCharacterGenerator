//
//  ResourcesAllocationView.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import SwiftUI

struct ResourcesAllocationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var character: Character
    let onComplete: () -> Void
    let onPrevious: (() -> Void)?
    @State private var selectedCategory: String = "All"
    @State private var selectedGear: [String: Int] = [:]
    @State private var selectedArmor: [String: Int] = [:]
    @State private var selectedLicenses: [String: Bool] = [:]

    private var nuyenRemaining: Int {
        let priorityResources = dataManager.priorityData.resources[character.priority?.resources ?? "E"] ?? 6000
        let gearCost = selectedGear.reduce(0) { total, item in
            if let gear = dataManager.gear.first(where: { $0.id == item.key }),
               let costString = gear.cost,
               let cost = Int(costString) {
                return total + (cost * item.value)
            }
            return total
        }
        let armorCost = selectedArmor.reduce(0) { total, item in
            if let armor = dataManager.armor.first(where: { $0.id == item.key }),
               let cost = Int(armor.cost) {
                return total + (cost * item.value)
            }
            return total
        }
        let licenseCost = selectedLicenses.reduce(0) { total, item in
            // Default license cost is 1000¥ since License struct has no cost field
            item.value ? total + 1000 : total
        }
        return priorityResources - gearCost - armorCost - licenseCost
    }

    private var gearCategories: [String] {
        ["All"] + Array(Set(dataManager.gear.map { $0.category }).sorted())
    }

    private var hasNegativeKarma: Bool {
        character.karma < 0
    }

    private var hasNegativeNuyen: Bool {
        nuyenRemaining < 0
    }

    private var isLowNuyen: Bool {
        nuyenRemaining <= 100 && nuyenRemaining >= 0
    }

    init(character: Binding<Character>, onComplete: @escaping () -> Void, onPrevious: (() -> Void)? = nil) {
        self._character = character
        self.onComplete = onComplete
        self.onPrevious = onPrevious
    }

    var body: some View {
        Form {
            errorSection
            if !dataManager.gear.isEmpty && !dataManager.armor.isEmpty && !dataManager.licenses.isEmpty && !hasNegativeKarma && !hasNegativeNuyen {
                resourcesSection
                gearSection
                armorSection
                licensesSection
                navigationSection
            }
        }
        .navigationTitle(NSLocalizedString("Resource Allocation", comment: "Title"))
        .onAppear {
            // Initialize with existing character selections
            selectedGear = character.gear.reduce(into: [String: Int]()) { result, item in
                if let gear = dataManager.gear.first(where: { $0.name == item.key }) {
                    result[gear.id] = item.value
                }
            }
            selectedArmor = character.gear.reduce(into: [String: Int]()) { result, item in
                if let armor = dataManager.armor.first(where: { $0.name == item.key }) {
                    result[armor.id] = item.value
                }
            }
            selectedLicenses = character.licenses.reduce(into: [String: Bool]()) { result, item in
                result[item.key] = item.value > 0
            }
        }
    }

    private var errorSection: some View {
        Group {
            if dataManager.errors["priorities"] != nil {
                Text("Error: Failed to load priority data. Please ensure priorities.json is present and correctly formatted.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.errors["gear"] != nil {
                Text("Error: Failed to load gear data. Please ensure gear.json contains valid gear entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.errors["armor"] != nil {
                Text("Error: Failed to load armor data. Please ensure armor.json contains valid armor entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.errors["licenses"] != nil {
                Text("Error: Failed to load licenses data. Please ensure licenses.json contains valid license entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.gear.isEmpty {
                Text("Error: No gear data available. Please ensure gear.json contains valid gear entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.armor.isEmpty {
                Text("Error: No armor data available. Please ensure armor.json contains valid armor entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if dataManager.licenses.isEmpty {
                Text("Error: No licenses data available. Please ensure licenses.json contains valid license entries.")
                    .foregroundColor(.red)
                    .padding()
            }
            if hasNegativeKarma {
                Text("Error: Karma is negative (\(character.karma)). Please adjust qualities or other karma expenditures.")
                    .foregroundColor(.red)
                    .padding()
            }
            if hasNegativeNuyen {
                Text("Error: Nuyen is negative (\(nuyenRemaining)¥). Please remove some gear, armor, or licenses.")
                    .foregroundColor(.red)
                    .padding()
            }
            if isLowNuyen {
                Text("Warning: Only \(nuyenRemaining)¥ remaining! Consider prioritizing essential gear.")
                    .foregroundColor(.orange)
                    .padding()
            }
        }
    }

    private var resourcesSection: some View {
        Section(header: Text(NSLocalizedString("Resources", comment: "Section header"))) {
            Text("Nuyen Remaining: \(nuyenRemaining)¥")
                .font(.headline)
            Picker("Category", selection: $selectedCategory) {
                ForEach(gearCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var gearSection: some View {
        Section(header: Text(NSLocalizedString("Gear", comment: "Section header"))) {
            ForEach(dataManager.gear.filter { selectedCategory == "All" || $0.category == selectedCategory }, id: \.id) { gear in
                HStack {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString(gear.name, comment: "Gear name"))
                            .font(.headline)
                        Text("Category: \(gear.category)")
                        if let costString = gear.cost, let cost = Int(costString) {
                            Text("Cost: \(cost)¥")
                        } else {
                            Text("Cost: Invalid")
                                .foregroundColor(.red)
                        }
                        Text("Source: \(gear.source), Page: \(gear.page)")
                    }
                    Spacer()
                    Button(action: {
                        selectedGear[gear.id, default: 0] += 1
                        character.gear[gear.name, default: 0] += 1
                        character.nuyen = nuyenRemaining
                    }) {
                        Text("Purchase")
                    }
                    .buttonStyle(.bordered)
                    .disabled(gear.cost == nil || Int(gear.cost!) == nil || nuyenRemaining < (Int(gear.cost!) ?? 0))
                }
            }
        }
    }

    private var armorSection: some View {
        Section(header: Text(NSLocalizedString("Armor", comment: "Section header"))) {
            ForEach(dataManager.armor, id: \.id) { armor in
                HStack {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString(armor.name, comment: "Armor name"))
                            .font(.headline)
                        Text("Armor: \(armor.armor)")
                        Text("Capacity: \(armor.armorcapacity)")
                        if let cost = Int(armor.cost) {
                            Text("Cost: \(cost)¥")
                        } else {
                            Text("Cost: Invalid")
                                .foregroundColor(.red)
                        }
                        Text("Availability: \(armor.avail)")
                    }
                    Spacer()
                    Button(action: {
                        selectedArmor[armor.id, default: 0] += 1
                        character.gear[armor.name, default: 0] += 1
                        character.nuyen = nuyenRemaining
                    }) {
                        Text("Purchase")
                    }
                    .buttonStyle(.bordered)
                    .disabled(Int(armor.cost) == nil || nuyenRemaining < (Int(armor.cost) ?? 0))
                }
            }
        }
    }

    private var licensesSection: some View {
        Section(header: Text(NSLocalizedString("Licenses", comment: "Section header"))) {
            ForEach(dataManager.licenses, id: \.name) { license in
                Toggle(NSLocalizedString(license.name, comment: "License name"), isOn: Binding(
                    get: { selectedLicenses[license.name, default: false] },
                    set: { newValue in
                        selectedLicenses[license.name] = newValue
                        character.licenses[license.name] = newValue ? 1 : 0
                        character.nuyen = nuyenRemaining
                    }
                ))
                .disabled(nuyenRemaining < 1000)
            }
        }
    }

    private var navigationSection: some View {
        Section {
            HStack {
                if onPrevious != nil {
                    Button("Previous") {
                        onPrevious?()
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
                Button("Next") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(hasNegativeNuyen || hasNegativeKarma)
            }
            .padding()
        }
    }
}

struct ResourcesAllocationView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesAllocationView(
            character: .constant(Character(
                name: "Test",
                metatype: "Human",
                priority: Character.PrioritySelection(
                    metatype: "A",
                    attributes: "B",
                    skills: "C",
                    magic: "D",
                    resources: "E"
                ),
                attributes: [:],
                skills: [:],
                specializations: [:],
                karma: 20,
                nuyen: 6000,
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
            onComplete: {},
            onPrevious: {}
        )
        .environmentObject({
            let dm = DataManager()
            dm.priorityData = PriorityData(
                metatype: [:],
                attributes: [:],
                skills: [:],
                magic: [
                    "D-Adept": MagicPriority(type: "Adept", points: 2, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil),
                    "E-Mundane": MagicPriority(type: "Mundane", points: 0, spells: nil, complexForms: nil, skillQty: nil, skillVal: nil, skillType: nil)
                ],
                resources: ["E": 6000]
            )
            dm.gear = [
                Gear(
                    id: "1",
                    name: "Pistol",
                    category: "Weapon",
                    rating: nil,
                    source: "Core",
                    page: "100",
                    avail: "4",
                    addweapon: nil,
                    cost: "300",
                    costfor: nil
                )
            ]
            dm.armor = [
                Armor(
                    id: "2",
                    name: "Urban Explorer Jumpsuit",
                    category: "Armor",
                    armor: "9",
                    armorcapacity: "10",
                    avail: "8",
                    cost: "650",
                    source: "Core",
                    page: "437"
                )
            ]
            dm.licenses = [
                License(name: "Firearms License")
            ]
            dm.errors = [:]
            return dm
        }())
    }
}
