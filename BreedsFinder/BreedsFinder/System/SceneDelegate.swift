//
//  SceneDelegate.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import UIKit
import SwiftUI
import Foundation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let environment = AppEnvironment.setup()
        let viewModel = AppContentView.ViewModel(container: environment.container)
        let contentView = AppContentView(viewModel: viewModel)
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
