//
//  BreedDetailView.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Models

struct BreedDetailView: View {
    let breed: Breed
    let imageSize: CGFloat = 300
    
    var body: some View {
        ScrollView {
            VStack {
                if let urlString = breed.imageUrl {
                    AsyncImage(url: URL(string: urlString)) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .scaledToFit()
                                .frame(height: imageSize)
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
                } else {
                    ZStack {
                        Color.gray.frame(height: imageSize)
                        Text("Image not found")
                            .font(Fonts.regular(30))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 25) {
                    
                    Text(breed.name)
                        .font(Fonts.bold(30))
                        .foregroundColor(.white)
                    Text(breed.temperament)
                        .font(Fonts.italic(16))
                        .foregroundColor(.white)
                    Text(breed.catExplaination)
                        .font(Fonts.regular(18))
                        .foregroundColor(.white)
                    if breed.isHairless != 0 {
                        Text("hairless")
                    }
                    
                    HStack {
                        Text("Energy level")
                            .font(Fonts.regular(18))
                            .foregroundColor(.white)
                        Spacer()
                        ForEach(1..<6) { id in
                            Image(systemName: "star.fill")
                                .foregroundColor(breed.energyLevel > id ? Color.yellow : Color.gray )
                        }
                    }
                    
                    Spacer()
                }.padding()
                    .navigationBarTitleDisplayMode(.inline)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Colors.main)
            .toolbarBackground(
                Colors.main ?? Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct BreedDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BreedDetailView(breed: Breed.example1())
    }
}
