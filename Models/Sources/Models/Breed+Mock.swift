//
//  Breed+Mock.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation

public extension Breed {
    static let mockedData: [Breed] = [
        Breed(name: "Abyssinian",
              id: "abys",
              explaination: "The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.",
              temperament: "Active, Energetic, Independent, Intelligent, Gentle",
              energyLevel: 5,
              isHairless: 0,
              imageUrl: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")
    ]
}
