//
//  RootViewAppearance.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine
import Infrastructure

struct RootViewAppearance: ViewModifier {
    
    @ObservedObject private(set) var viewModel: ViewModel
    internal let inspection = Inspection<Self>()
    
    func body(content: Content) -> some View {
        content.onReceive(inspection.notice) {
            self.inspection.visit(self, $0)
        }
    }
}

extension RootViewAppearance {
    class ViewModel: ObservableObject {
        
        @Published var isActive: Bool = false
        private let cancellableBag = CancellableBag()
        
        init(container: DIContainer) {
            container.appState.map(\.system.isActive)
                .removeDuplicates()
                .weakAssign(to: \.isActive, on: self)
                .insert(in: cancellableBag)
        }
    }
}
