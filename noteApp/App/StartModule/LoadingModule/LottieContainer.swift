import SwiftUI
import Lottie
import UIKit

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleToFill
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        let title: UILabel = {
            $0.text = "ПАП КУПИ"
            $0.textColor = .black
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.translatesAutoresizingMaskIntoConstraints = false
            return $0
        }(UILabel())
        view.addSubview(animationView)
        view.addSubview(title)

        NSLayoutConstraint.activate([
                animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                animationView.heightAnchor.constraint(equalToConstant: 350),

                title.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: -120),
                title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

