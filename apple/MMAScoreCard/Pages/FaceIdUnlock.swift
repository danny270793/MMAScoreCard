//
//  FaceIdUnlock.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI
import LocalAuthentication

struct FaceIdUnlock: View {
    var main: any View
    @State private var error: Error? = nil
    @State var authenticated = false
    @State var isAuthenticating = false
    let context = LAContext()
    
    private var biometryTypeName: String {
        switch context.biometryType {
        case LABiometryType.faceID: return "Face ID"
        case LABiometryType.touchID: return "Touch ID"
        default: return ""
        }
    }
    
    var body: some View {
        ZStack {
            if authenticated {
                AnyView(main)
            } else {
                ProgressView()
            }
        }
        .sheet(isPresented: .constant(!authenticated)) {
            VStack {
                Spacer()
                Text("\(biometryTypeName) authentication is required")
                if isAuthenticating {
                    ProgressView()
                } else {
                    Button("Authenticate") {
                        isAuthenticating = true
                        
                        var error: NSError?
                        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                            self.error = error
                            isAuthenticating = false
                            return
                        }
                        
                        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please authenticate to start ussig the app") { success, error in
                            DispatchQueue.main.async {
                                isAuthenticating = false
                                if success {
                                    self.authenticated = true
                                } else {
                                    self.authenticated = false
                                    self.error = error
                                }
                            }
                        }
                        
                        isAuthenticating = false
                    }
                }
                Spacer()
            }
            .alert(isPresented: .constant(error != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(error!.localizedDescription),
                    dismissButton: .default(Text("OK")) {
                        error = nil
                    }
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        FaceIdUnlock(main: EventsList())
    }
}
