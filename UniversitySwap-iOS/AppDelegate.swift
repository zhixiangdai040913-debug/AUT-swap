//
//  AppDelegate.swift
//  UniversitySwap
//
//  Created by 123 on 2026/10/22.
//

import Foundation

import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()

        print("Firebase initialized successfully!")

        return true
    }
}
