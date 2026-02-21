//
//  Sharing.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI

class Sharing {
    static func shareText(text: String) {
        let items: [Any] = [text]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityViewController, animated: true, completion: nil)
        }
    }
}
