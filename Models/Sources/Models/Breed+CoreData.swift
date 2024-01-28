//
//  Breed+CoreData.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import CoreData

extension BreedMO: ManagedEntity { }

public extension Breed {
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> BreedMO? {
        if !self.isExistedInDataBase(in: context) {
            guard let breedMO = BreedMO.insertNew(in: context)
            else { return nil }
            breedMO.name = name
            breedMO.id = id
            breedMO.temperament = temperament
            breedMO.catExplaination = catExplaination
            breedMO.energyLevel = Int32(energyLevel)
            breedMO.isHairless = Int32(isHairless)
            breedMO.imageUrl = imageUrl
            return breedMO
        }
        
        return nil
    }
    
    func isExistedInDataBase(in context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Breed")
        request.predicate = .init(format: "id == %@", self.id)
        do {
            let count = try context.count(for: request)
            return count > 0
        }
        catch {
            return false
        }
    }
    
    init?(managedObject: BreedMO) {
        guard let name = managedObject.name,
              let id = managedObject.id,
              let temperament = managedObject.temperament,
              let explaination = managedObject.catExplaination
        else { return nil }
        
        let energyLevel = managedObject.energyLevel
        let isHairless = managedObject.isHairless
        let imageUrl = managedObject.imageUrl
        
        self.init(name: name,
                  id: id,
                  explaination: explaination,
                  temperament: temperament,
                  energyLevel: Int(energyLevel),
                  isHairless: Int(isHairless),
                  imageUrl: imageUrl)
    }
}
