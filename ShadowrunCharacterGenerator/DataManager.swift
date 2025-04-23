//
//  DataManager.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var priorityData: PriorityData
    @Published var skills: [Skill]
    @Published var qualities: [Quality]
    @Published var gear: [Gear]
    @Published var armor: [Armor]
    @Published var weapons: [Weapon]
    @Published var cyberware: [Cyberware]
    @Published var bioware: [Bioware]
    @Published var vehicles: [Vehicle]
    @Published var programs: [Program]
    @Published var licenses: [License]
    @Published var lifestyles: [Lifestyle]
    @Published var contacts: [Contact]
    @Published var spells: [Spell]
    @Published var complexForms: [ComplexForm]
    @Published var powers: [Power]
    @Published var traditions: [Tradition]
    @Published var mentors: [Mentor]
    @Published var metamagic: [Metamagic]
    @Published var echoes: [Echo]
    @Published var spirits: [Spirit]
    @Published var improvements: [Improvement]
    @Published var books: [Book]
    @Published var martialArts: [MartialArt]
    @Published var ranges: [Range]
    @Published var actions: [Action]
    @Published var drugComponents: [DrugComponent]
    @Published var selectedSourcebooks: [String: URL] = [:] // Maps book codes to PDF URLs
    
    init() {
        // Load priorities
        let priorityURL = Bundle.main.url(forResource: "priorities", withExtension: "json")!
        priorityData = try! JSONDecoder().decode(PriorityData.self, from: Data(contentsOf: priorityURL))
        
        // Load skills
        let skillsURL = Bundle.main.url(forResource: "skills", withExtension: "json")!
        skills = try! JSONDecoder().decode([Skill].self, from: Data(contentsOf: skillsURL))
        
        // Load qualities
        let qualitiesURL = Bundle.main.url(forResource: "qualities", withExtension: "json")!
        qualities = try! JSONDecoder().decode([Quality].self, from: Data(contentsOf: qualitiesURL))
        
        // Load gear
        let gearURL = Bundle.main.url(forResource: "gear", withExtension: "json")!
        gear = try! JSONDecoder().decode([Gear].self, from: Data(contentsOf: gearURL))
        
        // Load armor
        let armorURL = Bundle.main.url(forResource: "armor", withExtension: "json")!
        armor = try! JSONDecoder().decode([Armor].self, from: Data(contentsOf: armorURL))
        
        // Load weapons
        let weaponsURL = Bundle.main.url(forResource: "weapons", withExtension: "json")!
        weapons = try! JSONDecoder().decode([Weapon].self, from: Data(contentsOf: weaponsURL))
        
        // Load cyberware
        let cyberwareURL = Bundle.main.url(forResource: "cyberware", withExtension: "json")!
        cyberware = try! JSONDecoder().decode([Cyberware].self, from: Data(contentsOf: cyberwareURL))
        
        // Load bioware
        let biowareURL = Bundle.main.url(forResource: "bioware", withExtension: "json")!
        bioware = try! JSONDecoder().decode([Bioware].self, from: Data(contentsOf: biowareURL))
        
        // Load vehicles
        let vehiclesURL = Bundle.main.url(forResource: "vehicles", withExtension: "json")!
        vehicles = try! JSONDecoder().decode([Vehicle].self, from: Data(contentsOf: vehiclesURL))
        
        // Load programs
        let programsURL = Bundle.main.url(forResource: "programs", withExtension: "json")!
        programs = try! JSONDecoder().decode([Program].self, from: Data(contentsOf: programsURL))
        
        // Load licenses
        let licensesURL = Bundle.main.url(forResource: "licenses", withExtension: "json")!
        licenses = try! JSONDecoder().decode([License].self, from: Data(contentsOf: licensesURL))
        
        // Load lifestyles
        let lifestylesURL = Bundle.main.url(forResource: "lifestyles", withExtension: "json")!
        lifestyles = try! JSONDecoder().decode([Lifestyle].self, from: Data(contentsOf: lifestylesURL))
        
        // Load contacts
        let contactsURL = Bundle.main.url(forResource: "contacts", withExtension: "json")!
        contacts = try! JSONDecoder().decode([Contact].self, from: Data(contentsOf: contactsURL))
        
        // Load spells
        let spellsURL = Bundle.main.url(forResource: "spells", withExtension: "json")!
        spells = try! JSONDecoder().decode([Spell].self, from: Data(contentsOf: spellsURL))
        
        // Load complex forms
        let complexFormsURL = Bundle.main.url(forResource: "complexforms", withExtension: "json")!
        complexForms = try! JSONDecoder().decode([ComplexForm].self, from: Data(contentsOf: complexFormsURL))
        
        // Load powers
        let powersURL = Bundle.main.url(forResource: "powers", withExtension: "json")!
        powers = try! JSONDecoder().decode([Power].self, from: Data(contentsOf: powersURL))
        
        // Load traditions
        let traditionsURL = Bundle.main.url(forResource: "traditions", withExtension: "json")!
        traditions = try! JSONDecoder().decode([Tradition].self, from: Data(contentsOf: traditionsURL))
        
        // Load mentors
        let mentorsURL = Bundle.main.url(forResource: "mentors", withExtension: "json")!
        mentors = try! JSONDecoder().decode([Mentor].self, from: Data(contentsOf: mentorsURL))
        
        // Load metamagic
        let metamagicURL = Bundle.main.url(forResource: "metamagic", withExtension: "json")!
        metamagic = try! JSONDecoder().decode([Metamagic].self, from: Data(contentsOf: metamagicURL))
        
        // Load echoes
        let echoesURL = Bundle.main.url(forResource: "echoes", withExtension: "json")!
        echoes = try! JSONDecoder().decode([Echo].self, from: Data(contentsOf: echoesURL))
        
        // Load spirits
        let spiritsURL = Bundle.main.url(forResource: "spirits", withExtension: "json")!
        spirits = try! JSONDecoder().decode([Spirit].self, from: Data(contentsOf: spiritsURL))
        
        // Load improvements
        let improvementsURL = Bundle.main.url(forResource: "improvements", withExtension: "json")!
        improvements = try! JSONDecoder().decode([Improvement].self, from: Data(contentsOf: improvementsURL))
        
        // Load books
        let booksURL = Bundle.main.url(forResource: "books", withExtension: "json")!
        books = try! JSONDecoder().decode([Book].self, from: Data(contentsOf: booksURL))
        
        // Load martial arts
        let martialArtsURL = Bundle.main.url(forResource: "martialarts", withExtension: "json")!
        martialArts = try! JSONDecoder().decode([MartialArt].self, from: Data(contentsOf: martialArtsURL))
        
        // Load ranges
        let rangesURL = Bundle.main.url(forResource: "ranges", withExtension: "json")!
        ranges = try! JSONDecoder().decode([Range].self, from: Data(contentsOf: rangesURL))
        
        // Load actions
        let actionsURL = Bundle.main.url(forResource: "actions", withExtension: "json")!
        actions = try! JSONDecoder().decode([Action].self, from: Data(contentsOf: actionsURL))
        
        // Load drug components
        let drugComponentsURL = Bundle.main.url(forResource: "drugcomponents", withExtension: "json")!
        drugComponents = try! JSONDecoder().decode([DrugComponent].self, from: Data(contentsOf: drugComponentsURL))
    }
}
