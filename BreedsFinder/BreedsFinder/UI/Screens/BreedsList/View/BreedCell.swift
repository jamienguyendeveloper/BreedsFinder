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
    var body: some View {
        VStack {
            if let imageUrl = breed.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFit()
                            .clipped()
                        
                     } else if phase.error != nil {
                         Text(phase.error?.localizedDescription ?? "error")
                             .foregroundColor(Color.pink)
                             .padding().padding(.top, 20)
                     } else {
                         AnyView(ActivityIndicatorView().padding().padding(.top, 20))
                     }
                    
                }
            } else {
                ZStack {
                    Color.gray.frame(height: 200)
                    Text("Image not found")
                        .font(Fonts.regular(20))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(breed.name)
                        .font(Fonts.bold(22))
                        .foregroundColor(Color.white)
                        .padding(.top, 20)
                        .padding(.leading, 20)
                    Spacer()
                }
                HStack {
                    Text(breed.temperament)
                        .multilineTextAlignment(.leading)
                        .font(Fonts.regular(16))
                        .foregroundColor(Color.white)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                    Spacer()
                }
            }
            Spacer()
        }.background(Colors.background)
            .cornerRadius(20)
     
    }
}

struct BreedCell_Previews: PreviewProvider {
    static var previews: some View {
        BreedCell(breed: Breed.mockedData[0])
            .previewLayout(.fixed(width: 375, height: 60))
    }
}
