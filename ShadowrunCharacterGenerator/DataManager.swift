//
//  DataManager.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    @Published var priorityData: PriorityData
    @Published var skills: [Skill] = []
    @Published var qualities: [Quality] = []
    @Published var lifestyleQualities: [LifestyleQuality] = []
    @Published var books: [Book] = []
    @Published var complexForms: [ComplexForm] = []
    @Published var contacts: [Contact] = []
    @Published var contactMetadata: ContactMetadata?
    @Published var echoes: [Echo] = []
    @Published var improvements: [Improvement] = []
    @Published var gear: [Gear] = []
    @Published var armor: [Armor] = []
    @Published var weapons: [Weapon] = []
    @Published var cyberware: [Cyberware] = []
    @Published var bioware: [Bioware] = []
    @Published var programs: [Program] = []
    @Published var licenses: [License] = []
    @Published var lifestyles: [Lifestyle] = []
    @Published var spells: [Spell] = []
    @Published var powers: [Power] = []
    @Published var traditions: [Tradition] = []
    @Published var mentors: [Mentor] = []
    @Published var metamagics: [Metamagic] = []
    @Published var martialArts: [MartialArt] = []
    @Published var metatypes: [Metatype] = []
    @Published var drugComponents: [DrugComponent] = []
    @Published var actions: [Action] = []
    @Published var ranges: [Range] = []
    @Published var selectedSourcebooks: [String: URL] = [:]
    @Published var errors: [String: String] = [:] // Resource name to error message
    
    private let userDefaultsKey = "selectedSourcebooks"

    // Make initializer accessible in debug builds for previews
    #if DEBUG
    init() {
        self.priorityData = PriorityData(
            metatype: [:],
            attributes: [:],
            skills: [:],
            magic: [:],
            resources: [:]
        )
        self.contactMetadata = nil
        loadData()
        loadSelectedSourcebooks()
    }
    #else
    private init() {
        self.priorityData = PriorityData(
            metatype: [:],
            attributes: [:],
            skills: [:],
            magic: [:],
            resources: [:]
        )
        self.contactMetadata = nil
        loadData()
        loadSelectedSourcebooks()
    }
    #endif

    private func loadData() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Helper to load JSON and set errors
        func load<T: Decodable>(_ resource: String, into property: inout [T], extract: @escaping (ChummerWrapper<T>) -> [T]?) {
            if let url = Bundle.main.url(forResource: resource, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let wrapper = try decoder.decode(ChummerWrapper<T>.self, from: data)
                    if let items = extract(wrapper) {
                        property = items
                        errors.removeValue(forKey: resource)
                    } else {
                        errors[resource] = "No data found in \(resource).json"
                    }
                } catch {
                    errors[resource] = "Failed to load \(resource).json: \(error.localizedDescription)"
                    print("Error decoding \(resource).json: \(error)")
                }
            } else {
                errors[resource] = "Missing \(resource).json in bundle"
            }
        }

        // Load books.json
        load("books", into: &books) { $0.chummer.books?.book }

        // Load complexforms.json
        load("complexforms", into: &complexForms) { $0.chummer.complexforms?.complexform }

        // Load contacts.json
        if let url = Bundle.main.url(forResource: "contacts", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(ContactWrapper.self, from: data)
                self.contacts = wrapper.chummer.contacts.contact.map { Contact(name: $0, connection: 1, loyalty: 1) }
                self.contactMetadata = ContactMetadata(
                    genders: wrapper.chummer.genders.gender,
                    types: wrapper.chummer.types.type,
                    preferredPayments: wrapper.chummer.preferredpayments.preferredpayment,
                    ages: wrapper.chummer.ages.age,
                    personalLives: wrapper.chummer.personallives.personallife,
                    hobbiesVices: wrapper.chummer.hobbiesvices.hobbyvice
                )
                errors.removeValue(forKey: "contacts")
            } catch {
                errors["contacts"] = "Failed to load contacts.json: \(error.localizedDescription)"
                print("Error decoding contacts.json: \(error)")
            }
        } else {
            errors["contacts"] = "Missing contacts.json in bundle"
        }

        // Load echoes.json
        load("echoes", into: &echoes) { $0.chummer.echoes?.echo }

        // Load improvements.json
        load("improvements", into: &improvements) { $0.chummer.improvements?.improvement }

        // Load priorities.json
        if let url = Bundle.main.url(forResource: "priorities", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(PriorityWrapper.self, from: data)
                self.priorityData = wrapper.toPriorityData()
                errors.removeValue(forKey: "priorities")
            } catch {
                errors["priorities"] = "Failed to load priorities.json: \(error.localizedDescription)"
                print("Error decoding priorities.json: \(error)")
            }
        } else {
            errors["priorities"] = "Missing priorities.json in bundle"
        }

        // Load skills.json (active and knowledge skills)
        if let url = Bundle.main.url(forResource: "skills", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(ChummerWrapper<Skill>.self, from: data)
                var allSkills: [Skill] = []
                if let activeSkills = wrapper.chummer.skills?.skill {
                    allSkills.append(contentsOf: activeSkills)
                }
                if let knowledgeSkills = wrapper.chummer.knowledgeskills?.skill {
                    allSkills.append(contentsOf: knowledgeSkills)
                }
                self.skills = allSkills
                errors.removeValue(forKey: "skills")
            } catch {
                errors["skills"] = "Failed to load skills.json: \(error.localizedDescription)"
                print("Error decoding skills.json: \(error)")
            }
        } else {
            errors["skills"] = "Missing skills.json in bundle"
        }

        // Load qualities.json
        load("qualities", into: &qualities) { $0.chummer.qualities?.quality }

        // Load gear.json
        load("gear", into: &gear) { $0.chummer.gears?.gear }

        // Load armor.json
        load("armor", into: &armor) { $0.chummer.armors?.armor }

        // Load weapons.json
        load("weapons", into: &weapons) { $0.chummer.weapons?.weapon }

        // Load cyberware.json
        load("cyberware", into: &cyberware) { $0.chummer.cyberwares?.cyberware }

        // Load bioware.json
        load("bioware", into: &bioware) { $0.chummer.biowares?.bioware }

        // Load programs.json
        load("programs", into: &programs) { $0.chummer.programs?.program }

        // Load licenses.json
        load("licenses", into: &licenses) { $0.chummer.licenses?.license }

        // Load lifestyles.json
        if let url = Bundle.main.url(forResource: "lifestyles", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(LifestyleChummerWrapper.self, from: data)
                if let lifestyles = wrapper.chummer.lifestyles?.lifestyle {
                    self.lifestyles = lifestyles
                    errors.removeValue(forKey: "lifestyles")
                } else {
                    errors["lifestyles"] = "No lifestyles found in lifestyles.json"
                }
                if let lifestyleQualities = wrapper.chummer.qualities?.quality {
                    self.lifestyleQualities = lifestyleQualities
                    errors.removeValue(forKey: "lifestyleQualities")
                } else {
                    errors["lifestyleQualities"] = "No lifestyle qualities found in lifestyles.json"
                }
            } catch {
                errors["lifestyles"] = "Failed to load lifestyles.json: \(error.localizedDescription)"
                print("Error decoding lifestyles.json: \(error)")
            }
        } else {
            errors["lifestyles"] = "Missing lifestyles.json in bundle"
        }

        // Load spells.json
        load("spells", into: &spells) { $0.chummer.spells?.spell }

        // Load powers.json
        load("powers", into: &powers) { $0.chummer.powers?.power }

        // Load traditions.json
        load("traditions", into: &traditions) { $0.chummer.traditions?.tradition }

        // Load mentors.json
        load("mentors", into: &mentors) { $0.chummer.mentors?.mentor }

        // Load metamagic.json
        load("metamagic", into: &metamagics) { $0.chummer.metamagics?.metamagic }

        // Load martialarts.json
        load("martialarts", into: &martialArts) { $0.chummer.martialarts?.martialart }

        // Load metatypes.json
        load("metatypes", into: &metatypes) { $0.chummer.metatypes?.metatype }

        // Load drugcomponents.json
        load("drugcomponents", into: &drugComponents) { $0.chummer.drugcomponents?.drugcomponent }

        // Load actions.json
        load("actions", into: &actions) { $0.chummer.actions?.action }

        // Load ranges.json
        load("ranges", into: &ranges) { $0.chummer.ranges?.range }
    }
    
    // Save selectedSourcebooks to UserDefaults as bookmarks
    func saveSelectedSourcebooks() {
        var bookmarks: [String: Data] = [:]
        for (code, url) in selectedSourcebooks {
            do {
                let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                bookmarks[code] = bookmarkData
            } catch {
                print("Error creating bookmark for \(url): \(error)")
            }
        }
        UserDefaults.standard.set(bookmarks, forKey: userDefaultsKey)
    }
    
    // Load selectedSourcebooks from UserDefaults
    private func loadSelectedSourcebooks() {
        if let bookmarks = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: Data] {
            for (code, bookmarkData) in bookmarks {
                do {
                    var isStale = false
                    let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    if !isStale {
                        if url.startAccessingSecurityScopedResource() {
                            selectedSourcebooks[code] = url
                        }
                    }
                } catch {
                    print("Error resolving bookmark for \(code): \(error)")
                }
            }
        }
    }
}

// Generic ChummerWrapper for most resources
struct ChummerWrapper<T: Decodable>: Decodable {
    let chummer: ChummerData
    struct ChummerData: Decodable {
        let books: Books?
        let complexforms: ComplexForms?
        let echoes: Echoes?
        let improvements: Improvements?
        let skills: Skills?
        let knowledgeskills: KnowledgeSkills?
        let qualities: Qualities?
        let gears: Gears?
        let armors: Armors?
        let weapons: Weapons?
        let cyberwares: Cyberwares?
        let biowares: Biowares?
        let programs: Programs?
        let licenses: Licenses?
        let lifestyles: Lifestyles?
        let spells: Spells?
        let powers: Powers?
        let traditions: Traditions?
        let mentors: Mentors?
        let metamagics: Metamagics?
        let martialarts: MartialArts?
        let metatypes: Metatypes?
        let drugcomponents: DrugComponents?
        let actions: Actions?
        let ranges: Ranges?
    }
    struct Books: Decodable { let book: [Book] }
    struct ComplexForms: Decodable { let complexform: [ComplexForm] }
    struct Echoes: Decodable { let echo: [Echo] }
    struct Improvements: Decodable { let improvement: [Improvement] }
    struct Skills: Decodable { let skill: [Skill] }
    struct KnowledgeSkills: Decodable { let skill: [Skill] }
    struct Qualities: Decodable { let quality: [Quality] }
    struct Gears: Decodable { let gear: [Gear] }
    struct Armors: Decodable { let armor: [Armor] }
    struct Weapons: Decodable { let weapon: [Weapon] }
    struct Cyberwares: Decodable { let cyberware: [Cyberware] }
    struct Biowares: Decodable { let bioware: [Bioware] }
    struct Programs: Decodable { let program: [Program] }
    struct Licenses: Decodable { let license: [License] }
    struct Lifestyles: Decodable { let lifestyle: [Lifestyle] }
    struct Spells: Decodable { let spell: [Spell] }
    struct Powers: Decodable { let power: [Power] }
    struct Traditions: Decodable { let tradition: [Tradition] }
    struct Mentors: Decodable { let mentor: [Mentor] }
    struct Metamagics: Decodable { let metamagic: [Metamagic] }
    struct MartialArts: Decodable { let martialart: [MartialArt] }
    struct Metatypes: Decodable { let metatype: [Metatype] }
    struct DrugComponents: Decodable { let drugcomponent: [DrugComponent] }
    struct Actions: Decodable { let action: [Action] }
    struct Ranges: Decodable { let range: [Range] }
}

// Specific ChummerWrapper for lifestyles.json
struct LifestyleChummerWrapper: Decodable {
    let chummer: ChummerData
    struct ChummerData: Decodable {
        let lifestyles: Lifestyles?
        let qualities: LifestyleQualities?
    }
    struct Lifestyles: Decodable { let lifestyle: [Lifestyle] }
    struct LifestyleQualities: Decodable { let quality: [LifestyleQuality] }
}

// Wrapper Structs for JSON Decoding
struct ContactWrapper: Decodable {
    let chummer: ChummerContacts
    struct ChummerContacts: Decodable {
        let contacts: Contacts
        let genders: Genders
        let types: Types
        let preferredpayments: PreferredPayments
        let ages: Ages
        let personallives: PersonalLives
        let hobbiesvices: HobbiesVices
    }
    struct Contacts: Decodable {
        let contact: [String]
    }
    struct Genders: Decodable {
        let gender: [String]
    }
    struct Types: Decodable {
        let type: [String]
    }
    struct PreferredPayments: Decodable {
        let preferredpayment: [String]
    }
    struct Ages: Decodable {
        let age: [String]
    }
    struct PersonalLives: Decodable {
        let personallife: [String]
    }
    struct HobbiesVices: Decodable {
        let hobbyvice: [String]
    }
}

struct ContactMetadata {
    let genders: [String]
    let types: [String]
    let preferredPayments: [String]
    let ages: [String]
    let personalLives: [String]
    let hobbiesVices: [String]
}

struct PriorityWrapper: Decodable {
    let chummer: ChummerPriorities
    
    struct ChummerPriorities: Decodable {
        let priorities: Priorities
    }
    
    struct Priorities: Decodable {
        let priority: [RawPriorityData]
    }
}

struct RawPriorityData: Decodable {
    let id: String
    let name: String
    let value: String
    let category: String
    let metatypes: Metatypes?
    let talents: Talents?
    let attributes: String?
    let skills: String?
    let skillgroups: String?
    let resources: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, value, category, metatypes, talents, attributes, skills, skillgroups, resources
    }
    
    struct Metatypes: Decodable {
        let metatype: [Metatype]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // Handle both single metatype and array
            if let singleMetatype = try? container.decode(Metatype.self, forKey: .metatype) {
                self.metatype = [singleMetatype]
            } else {
                self.metatype = try container.decode([Metatype].self, forKey: .metatype)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case metatype
        }
        
        struct Metatype: Decodable {
            let name: String
            let value: String
            let karma: String
            let metavariants: Metavariants?
            
            struct Metavariants: Decodable {
                let metavariant: [Metavariant]?
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    // Handle both single metavariant and array
                    if let singleMetavariant = try? container.decode(Metavariant.self, forKey: .metavariant) {
                        self.metavariant = [singleMetavariant]
                    } else {
                        self.metavariant = try container.decodeIfPresent([Metavariant].self, forKey: .metavariant)
                    }
                }
                
                enum CodingKeys: String, CodingKey {
                    case metavariant
                }
                
                struct Metavariant: Decodable {
                    let name: String
                    let value: String
                    let karma: String
                }
            }
        }
    }
    
    struct Talents: Decodable {
        let talent: [Talent]
        
        struct Talent: Decodable {
            let name: String
            let value: String
            let qualities: Qualities?
            let magic: String?
            let spells: String?
            let resonance: String?
            let cfp: String?
            let depth: String?
            let skillqty: String?
            let skillval: String?
            let skilltype: AnyCodable?
            let skillgroupchoices: SkillGroupChoices?
            let skillchoices: SkillChoices?
            let skillgroupqty: String?
            let skillgroupval: String?
            let skillgrouptype: String?
            
            struct Qualities: Decodable {
                let quality: String
            }
            
            struct SkillGroupChoices: Decodable {
                let skillgroup: [String]
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    // Handle both single skillgroup and array
                    if let singleSkillgroup = try? container.decode(String.self, forKey: .skillgroup) {
                        self.skillgroup = [singleSkillgroup]
                    } else {
                        self.skillgroup = try container.decode([String].self, forKey: .skillgroup)
                    }
                }
                
                enum CodingKeys: String, CodingKey {
                    case skillgroup
                }
            }
            
            struct SkillChoices: Decodable {
                let skill: [String]
            }
        }
    }
}

extension PriorityWrapper {
    func toPriorityData() -> PriorityData {
        var metatype: [String: [MetatypeOption]] = [:]
        var attributes: [String: Int] = [:]
        var skills: [String: SkillPriority] = [:]
        var magic: [String: MagicPriority] = [:]
        var resources: [String: Int] = [:]
        
        for priority in chummer.priorities.priority {
            let level = priority.value
            switch priority.category {
            case "Heritage":
                if let metatypes = priority.metatypes?.metatype {
                    var options: [MetatypeOption] = []
                    for metatype in metatypes {
                        options.append(MetatypeOption(
                            name: metatype.name,
                            specialAttributePoints: Int(metatype.value) ?? 0,
                            karma: Int(metatype.karma)
                        ))
                        if let variants = metatype.metavariants?.metavariant?.compactMap({ $0 }) {
                            options.append(contentsOf: variants.map { variant in
                                MetatypeOption(
                                    name: variant.name,
                                    specialAttributePoints: Int(variant.value) ?? 0,
                                    karma: Int(variant.karma)
                                )
                            })
                        }
                    }
                    metatype[level] = options
                }
            case "Attributes":
                if let attr = priority.attributes, let attrInt = Int(attr) {
                    attributes[level] = attrInt
                }
            case "Skills":
                if let skillPoints = priority.skills, let skillGroupPoints = priority.skillgroups,
                   let skillPointsInt = Int(skillPoints), let skillGroupPointsInt = Int(skillGroupPoints) {
                    skills[level] = SkillPriority(
                        skillPoints: skillPointsInt,
                        skillGroupPoints: skillGroupPointsInt
                    )
                }
            case "Talent":
                if let talents = priority.talents?.talent {
                    for talent in talents {
                        var points = 0
                        if let magic = talent.magic, let magicInt = Int(magic) {
                            points = magicInt
                        } else if let resonance = talent.resonance, let resInt = Int(resonance) {
                            points = resInt
                        } else if let depth = talent.depth, let depthInt = Int(depth) {
                            points = depthInt
                        }
                        magic[level + "-" + talent.value] = MagicPriority(
                            type: talent.value,
                            points: points,
                            spells: talent.spells.flatMap { Int($0) },
                            complexForms: talent.cfp.flatMap { Int($0) },
                            skillQty: talent.skillqty.flatMap { Int($0) },
                            skillVal: talent.skillval.flatMap { Int($0) },
                            skillType: talent.skilltype?.value as? String
                        )
                    }
                }
            case "Resources":
                if let res = priority.resources, let resInt = Int(res) {
                    resources[level] = resInt
                }
            default:
                break
            }
        }
        
        return PriorityData(
            metatype: metatype,
            attributes: attributes,
            skills: skills,
            magic: magic,
            resources: resources
        )
    }
}
