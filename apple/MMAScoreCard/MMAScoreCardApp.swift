//
//  MMAScoreCardApp.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import LocalAuthentication

@main
struct MMAScoreCardApp: App {
    @State private var error: Error? = nil
    @State var authenticated = false
    @State var authenticating = false
    @State var useFaceId = UserDefaults.standard.bool(forKey: "useFaceId")
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if useFaceId && !authenticated {
                    Text("Face ID authentication is required")
                        .alert(isPresented: .constant(error != nil)) {
                            Alert(
                                title: Text("Error"),
                                message: Text(error!.localizedDescription),
                                dismissButton: .default(Text("OK")) {
                                    error = nil
                                }
                            )
                        }
                        
                    if authenticating {
                        ProgressView()
                    } else {
                        Button("Authenticate") {
                            authenticating = true
                            let context = LAContext()
                            var error: NSError?
                            
                            if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                                self.error = error
                                authenticating = false
                                return
                            }
                            
//                            if context.biometryType == .faceID {
//                                print("Face ID is available.")
//                            } else if context.biometryType == .touchID {
//                                print("Touch ID is available.")
//                            }
                            
                            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please authenticate to start ussig the app") { success, error in
                                DispatchQueue.main.async {
                                    authenticating = false
                                    if success {
                                        self.authenticated = true
                                    } else {
                                        self.authenticated = false
                                        self.error = error
                                    }
                                }
                            }
                        }
                    }
                } else {
                    EventsList()
                }
            }
        }
    }
}
