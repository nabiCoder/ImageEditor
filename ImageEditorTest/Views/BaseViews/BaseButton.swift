import SwiftUI

enum ButtonStyles {
    case bordered
    case borderedProminent
    case plain
}

struct BaseButton2: View {
    
    let title: String
    var isDisabled: Bool = false
    var style: ButtonStyles = .borderedProminent
    
    let action: () -> Void
    
    @ViewBuilder
    var styledButton: some View {
        switch style {
        case .bordered:
            Button(title, action: action)
                .buttonStyle(.bordered)
        case .borderedProminent:
            Button(title, action: action)
                .buttonStyle(.borderedProminent)
        case .plain:
            Button(title, action: action)
                .buttonStyle(.plain)
        }
    }
    
    var body: some View {
        styledButton
            .modifier(BaseButtonModifier(isDisabled: isDisabled))
            .disabled(isDisabled)
    }
}

enum BaseButtonStyle {
    case filled
    case outlined
    case plain
}

struct BaseButton: View {
    
    let title: String
    var isDisabled: Bool = false
    var style: BaseButtonStyle = .filled
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)          // растягиваем по ширине
                .padding(.vertical, 12)              // вертикальный padding
                .background(backgroundColor)         // фон в зависимости от стиля
                .foregroundColor(foregroundColor)    // цвет текста
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .cornerRadius(8)
                .opacity(isDisabled ? 0.5 : 1)
        }
        .disabled(isDisabled)
    }
    
    // MARK: - Вспомогательные свойства для стилей
    private var backgroundColor: Color {
        switch style {
        case .filled:
            return isDisabled ? Color.gray.opacity(0.3) : Color.accentColor
        case .outlined, .plain:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .filled:
            return isDisabled ? Color.gray : Color.white
        case .plain:
            return Color.red
        case .outlined:
            return Color.black
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outlined:
            return isDisabled ? Color.gray.opacity(0.5) : Color.accentColor
        default:
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return 0
        default:
            return 0
        }
    }
}

