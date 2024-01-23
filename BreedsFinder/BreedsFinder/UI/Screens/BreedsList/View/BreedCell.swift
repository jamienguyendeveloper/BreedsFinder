//
//  BreedCell.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Models

struct BreedCell: View {
    
    let breed: Breed
    let imageSize: CGFloat = 100
    var body: some View {
        HStack {
            
            if let imageUrl = breed.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .clipped()
                        
                     } else if phase.error != nil {
                         
                         Text(phase.error?.localizedDescription ?? "error")
                             .foregroundColor(Color.pink)
                             .frame(width: imageSize, height: imageSize)
                     } else {
                        ProgressView()
                             .frame(width: imageSize, height: imageSize)
                     }
                    
                }
            }else {
                Color.gray.frame(width: imageSize, height: imageSize)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(breed.name)
                    .font(.headline)
                Text(breed.temperament)
            }
        }
     
    }
}

struct BreedCell_Previews: PreviewProvider {
    static var previews: some View {
        BreedCell(breed: Breed.mockedData[0])
            .previewLayout(.fixed(width: 375, height: 60))
    }
}
