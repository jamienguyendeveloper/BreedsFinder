//
//  BreedMO+Ext.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import CoreData

public extension BreedMO {
    public static func justOneBreed() -> NSFetchRequest<BreedMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "USA")
        request.fetchLimit = 1
        return request
    }
    
    public static func searchBreeds(search: String) -> NSFetchRequest<BreedMO> {
        let request = newFetchRequest()
        if search.count == 0 {
            request.predicate = NSPredicate(value: true)
        } else {
            let nameMatch = NSPredicate(format: "name CONTAINS[cd] %@", search)
            request.predicate = NSCompoundPredicate(type: .or, subpredicates: [nameMatch])
        }
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 10
        return request
    }
}
