import SwiftUI

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.1)
            .animation(.easeInOut, value: configuration.isPressed)
            .shadow(radius: 10)
            .focusable()
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(configuration.isPressed ? Color.white.opacity(0.3) : Color.white.opacity(0.2)))
            .brightness(configuration.isPressed ? 0.2 : 0)
    }
}

extension ButtonStyle where Self == CardButtonStyle {
    static var customCard: CardButtonStyle { .init() }
}