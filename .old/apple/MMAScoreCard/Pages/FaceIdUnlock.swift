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
    var requiresFaceId = UserDefaults.standard.bool(forKey: "useFaceId")
    
    private var biometryTypeName: String {
        switch context.biometryType {
        case LABiometryType.faceID: return String(localized: "auth.face_id")
        case LABiometryType.touchID: return String(localized: "auth.touch_id")
        default: return ""
        }
    }
    
    func doBiometricAuthentication() {
        isAuthenticating = true
        
        var error: NSError?
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.error = error
            isAuthenticating = false
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: String(localized: "auth.reason")) { success, error in
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
    
    var body: some View {
        ZStack {
            if requiresFaceId {
                if authenticated {
                    AnyView(main)
                } else {
                    ProgressView()
                }
            } else {
                AnyView(main)
            }
        }
        .sheet(isPresented: .constant(requiresFaceId && !authenticated)) {
            VStack {
                Spacer()
                Text(String(format: String(localized: "auth.required"), biometryTypeName))
                if isAuthenticating {
                    ProgressView()
                } else {
                    Button(String(localized: "auth.authenticate")) {
                        doBiometricAuthentication()
                    }
                }
                Spacer()
            }
            .onAppear {
                doBiometricAuthentication()
            }
            .alert(isPresented: .constant(error != nil)) {
                Alert(
                    title: Text(String(localized: "common.error")),
                    message: Text(error!.localizedDescription),
                    dismissButton: .default(Text(String(localized: "common.ok"))) {
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
