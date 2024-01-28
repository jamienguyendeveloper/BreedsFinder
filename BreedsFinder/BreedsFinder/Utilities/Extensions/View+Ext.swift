//
//  View+Ext.swift
//  BreedsFinder
//
//  Created by Jamie on 29/01/2024.
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 0.5 : 0)
            self
        }
    }
}
