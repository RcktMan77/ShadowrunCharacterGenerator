//
//  Models.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import Foundation

// Core character struct
struct Character: Codable {
    var name: String
    var metatype: String
    var attributes: [String: Int]
    var skills: [String: Int]
    var karma: Int
    var nuyen: Int
    var gear: [String: Int] // e.g., ["Commlink": 1] for quantity
    var qualities: [String: Int] // e.g., ["Ambidextrous": 4] for karma cost
    var contacts: [String: Contact] // e.g., ["Fixer": Contact]
    var spells: [String] // List of spell names
    var complexForms: [String] // List of complex form names
    var powers: [String: Double] // e.g., ["Improved Reflexes": 1.5] for power points
    var mentor: String? // Mentor spirit name
    var tradition: String? // Magical tradition
    var metamagic: [String] // List of metamagic names
    var echoes: [String] // List of echo names
    var licenses: [String: Int] // e.g., ["Firearms License": 1] for quantity
    var lifestyle: String? // Lifestyle name
    var martialArts: [String] // List of martial arts techniques
    var sourcebooks: [String]
}

// Priority data (from priorities.json)
struct PriorityData: Codable {
    var metatype: [String: [MetatypeOption]]
    var attributes: [String: Int]
    var skills: [String: SkillPriority]
    var magic: [String: MagicPriority]
    var resources: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case metatype = "Metatype"
        case attributes = "Attributes"
        case skills = "Skills"
        case magic = "Magic"
        case resources = "Resources"
    }
}

struct MetatypeOption: Codable {
    var name: String
    var specialAttributePoints: Int
}

struct SkillPriority: Codable {
    var skillPoints: Int
    var skillGroupPoints: Int
}

struct MagicPriority: Codable {
    var type: String
    var points: Int
}

// Skills (from skills.json)
struct Skill: Codable {
    let id: String
    let name: String
    let attribute: String
    let category: String
    let `default`: String
    let skillgroup: String?
    let specs: [String]?
    let source: String
    let page: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, attribute, category, `default`, skillgroup, source, page
        case specs = "specs"
    }
}

// Qualities (from qualities.json)
struct Quality: Codable {
    let id: String
    let name: String
    let karma: String
    let category: String
    let limit: String?
    let bonus: [String: [String: String]]?
    let source: String
    let page: String
}

// Gear (from gear.json)
struct Gear: Codable {
    let id: String
    let name: String
    let category: String
    let rating: String?
    let source: String
    let page: String
    let avail: String?
    let addweapon: String?
    let cost: String?
    let costfor: String?
}

// Armor (from armor.json)
struct Armor: Codable {
    let id: String
    let name: String
    let category: String
    let armor: String
    let armorcapacity: String
    let avail: String
    let cost: String
    let source: String
    let page: String
}

// Weapons (from weapons.json)
struct Weapon: Codable {
    let id: String
    let name: String
    let category: String
    let type: String
    let conceal: String
    let accuracy: String
    let reach: String
    let damage: String
    let ap: String
    let mode: String
    let rc: String
    let ammo: String
    let avail: String
    let cost: String
    let source: String
    let page: String
    let accessories: [Accessory]?
    let accessorymounts: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, type, conceal, accuracy, reach, damage, ap, mode, rc, ammo, avail, cost, source, page
        case accessories = "accessories"
        case accessorymounts = "accessorymounts"
    }
}

struct Accessory: Codable {
    let name: String
}

// Cyberware (from cyberware.json)
struct Cyberware: Codable {
    let id: String
    let name: String
    let limit: String?
    let category: String
    let ess: String
    let capacity: String
    let avail: String
    let cost: String
    let source: String
    let page: String
    let rating: String?
    let forcegrade: String?
    let required: [String: [String: [String: String]]]?
}

// Bioware (from bioware.json)
struct Bioware: Codable {
    let id: String
    let name: String
    let category: String
    let ess: String
    let capacity: String
    let avail: String
    let cost: String
    let rating: String?
    let source: String
    let page: String
}

// Vehicles (from vehicles.json)
struct Vehicle: Codable {
    let id: String
    let name: String
    let page: String
    let source: String
    let accel: String
    let armor: String
    let avail: String
    let body: String
    let category: String
    let cost: String
    let handling: String
    let pilot: String
    let sensor: String
    let speed: String
    let gears: [Gear]?
    let mods: [String]?
    let seats: String
}

// Programs (from programs.json)
struct Program: Codable {
    let id: String
    let name: String
    let category: String
    let avail: String
    let cost: String
    let source: String
    let page: String
}

// Licenses (from licenses.json)
struct License: Codable {
    let name: String
}

// Lifestyles (from lifestyles.json)
struct Lifestyle: Codable {
    let id: String
    let name: String
    let cost: String
    let dice: String?
    let lp: String?
    let multiplier: String?
    let source: String
    let page: String
}

// Contacts (from contacts.json)
struct Contact: Codable {
    let name: String
    let connection: Int
    let loyalty: Int
}

// Spells (from spells.json)
struct Spell: Codable {
    let id: String
    let name: String
    let page: String
    let source: String
    let category: String
    let damage: String?
    let descriptor: String?
    let duration: String
    let dv: String
    let range: String
    let type: String
}

// Complex Forms (from complexforms.json)
struct ComplexForm: Codable {
    let id: String
    let name: String
    let target: String
    let duration: String
    let fv: String
    let source: String
    let page: String
}

// Powers (from powers.json)
struct Power: Codable {
    let id: String
    let name: String
    let points: String
    let levels: String
    let limit: String?
    let source: String
    let page: String
    let action: String?
}

// Traditions (from traditions.json)
struct Tradition: Codable {
    let id: String
    let name: String
    let drain: [String: String]?
    let source: String
    let page: String
    let spirits: [String: String]?
}

// Mentors (from mentors.json)
struct Mentor: Codable {
    let id: String
    let name: String
    let advantage: String
    let disadvantage: String
    let bonus: [String: String]?
    let choices: [Choice]?
    let source: String
    let page: String
}

struct Choice: Codable {
    let name: String
    let bonus: [String: [String: String]]?
}

// Metamagic (from metamagic.json)
struct Metamagic: Codable {
    let id: String
    let name: String
    let adept: String?
    let magician: String?
    let source: String
    let page: String
}

// Echoes (from echoes.json)
struct Echo: Codable {
    let id: String
    let name: String
    let source: String
    let page: String
    let bonus: [String: [String: String]]?
    let limit: String?
}

// Spirits (from spirits.json)
struct Spirit: Codable {
    let id: String
    let name: String
    let bod: String
    let agi: String
    let rea: String
    let str: String
    let cha: String
    let int: String
    let log: String
    let wil: String
    let ini: String
    let source: String
    let page: String
    let optionalpowers: [String]?
    let powers: [String]?
    let skills: [Skill]?
}

// Improvements (from improvements.json)
struct Improvement: Codable {
    let id: String
    let name: String
    let `internal`: String?
    let fields: [String]?
    let xml: String?
    let page: String?
}

// Books (from books.json)
struct Book: Codable {
    let id: String
    let name: String
    let code: String
    let matches: [Match]?
}

struct Match: Codable {
    let language: String
    let text: String
    let page: String
}

// Martial Arts (from martialarts.json)
struct MartialArt: Codable {
    let id: String
    let name: String
    let bonus: [String: [String: String]]?
    let techniques: [String]?
    let source: String
    let page: String
}

// Ranges (from ranges.json)
struct Range: Codable {
    let name: String
    let min: String
    let short: String
    let medium: String
    let long: String
    let extreme: String
}

// Actions (from actions.json)
struct Action: Codable {
    let name: String
    let type: String
    let requirements: String?
}

// Drug Components (from drugcomponents.json)
struct DrugComponent: Codable {
    let id: String
    let name: String
    let category: String
    let effects: [Effect]?
    let availability: String
    let cost: String
    let rating: String?
    let threshold: String?
    let source: String
    let page: String
}

struct Effect: Codable {
    let level: String
    let attribute: [Attribute]?
    let quality: Quality?
}

struct Attribute: Codable {
    let name: String
    let value: String
}

// Metatypes (from metatypes.json)
struct Metatype: Codable {
    let id: String
    let name: String
    let karma: String
    let category: String
    let bodmin: String
    let bodmax: String
    let bodaug: String
    let agimin: String
    let agimax: String
    let agiaug: String
    let reamin: String
    let reamax: String
    let reaaug: String
    let strmin: String
    let strmax: String
    let straug: String
    let chamin: String
    let chamax: String
    let chaaug: String
    let intmin: String
    let intmax: String
    let intaug: String
    let logmin: String
    let logmax: String
    let logaug: String
    let wilmin: String
    let wilmax: String
    let wilaug: String
    let inimin: String
    let inimax: String
    let iniaug: String
    let edgmin: String
    let edgmax: String
    let edgaug: String
    let magmin: String
    let magmax: String
    let magaug: String
    let resmin: String
    let resmax: String
    let resaug: String
    let essmin: String
    let essmax: String
    let essaug: String
    let depmin: String
    let depmax: String
    let depaug: String
    let walk: String
    let run: String
    let sprint: String
    let bonus: [String: String]?
    let source: String
    let page: String
    let metavariants: [Metavariant]?
}

struct Metavariant: Codable {
    let id: String
    let name: String
    let category: String
    let karma: String
    let bodmin: String
    let bodmax: String
    let bodaug: String
    let agimin: String
    let agimax: String
    let agiaug: String
    let reamin: String
    let reamax: String
    let reaaug: String
    let strmin: String
    let strmax: String
    let straug: String
    let chamin: String
    let chamax: String
    let chaaug: String
    let intmin: String
    let intmax: String
    let intaug: String
    let logmin: String
    let logmax: String
    let logaug: String
    let wilmin: String
    let wilmax: String
    let wilaug: String
    let inimin: String
    let inimax: String
    let iniaug: String
    let edgmin: String
    let edgmax: String
    let edgaug: String
    let magmin: String
    let magmax: String
    let magaug: String
    let resmin: String
    let resmax: String
    let resaug: String
    let essmin: String
    let essmax: String
    let essaug: String
    let depmin: String
    let depmax: String
    let depaug: String
    let qualities: Qualities?
    let bonus: [String: String]?
    let source: String
    let page: String
}

struct Qualities: Codable {
    let positive: Quality?
    let negative: Quality?
}
