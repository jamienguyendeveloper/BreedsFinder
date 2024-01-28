//
//  Fonts.swift
//  BreedsFinder
//
//  Created by Jamie on 28/01/2024.
//

import SwiftUI

struct Fonts {
    static func regular(_ size: CGFloat) -> Font? {
        return Font.custom("WorkSans-Regular", size: size)
    }
    
    static func light(_ size: CGFloat) -> Font? {
        return Font.custom("WorkSans-Light", size: size)
    }
    
    static func bold(_ size: CGFloat) -> Font? {
        return Font.custom("WorkSans-Bold", size: size)
    }
    
    static func italic(_ size: CGFloat) -> Font? {
        return Font.custom("WorkSans-Italic", size: size)
    }
}
