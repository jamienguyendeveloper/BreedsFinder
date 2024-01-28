//
//  Breed.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation

public struct Breed: Codable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let temperament: String
    public let catExplaination: String
    public let energyLevel: Int
    public let isHairless: Int
    public var imageUrl: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case temperament
        case catExplaination = "description"
        case energyLevel = "energy_level"
        case isHairless = "hairless"
        case imageUrl = "image"
    }
    
    enum ImageKeys: String, CodingKey {
        case url
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        temperament = try values.decode(String.self, forKey: .temperament)
        catExplaination = try values.decode(String.self, forKey: .catExplaination)
        energyLevel = try values.decode(Int.self, forKey: .energyLevel)
        isHairless = try values.decode(Int.self, forKey: .isHairless)
        
        let imageContainer = try? values.nestedContainer(keyedBy: ImageKeys.self, forKey: .imageUrl)
        imageUrl = try? imageContainer?.decode(String.self, forKey: .url)
    }
    
    public init(name: String,
                id: String,
                explaination: String,
                temperament: String,
                energyLevel: Int,
                isHairless: Int,
                imageUrl: String?) {
        self.id = id
        self.name = name
        self.catExplaination = explaination
        self.energyLevel = energyLevel
        self.temperament = temperament
        self.isHairless = isHairless
        self.imageUrl = imageUrl
    }
    
    public static func == (lhs: Breed, rhs: Breed) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func example1() -> Breed {
        return Breed(name: "Abyssinian",
                     id: "abys",
                     explaination: "The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.",
                     temperament: "Active, Energetic, Independent, Intelligent, Gentle",
                     energyLevel: 5,
                     isHairless: 0,
                     imageUrl: "https://cdn2.thecatapi.com/images/unX21IBVB.jpg")
        
    }
}
