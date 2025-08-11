import SwiftUI
import Lottie

struct LoadView: View {
    
    @State private var isActive = false
    
    var body: some View {
        
        Group {
            if isActive {
                OnboardingView()
            } else {
                LottieView(name: "Notes", loopMode: .loop)
                    .frame(width: 300, height: 500)
                    .background(Color.white)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
            }
        }
    }
}
