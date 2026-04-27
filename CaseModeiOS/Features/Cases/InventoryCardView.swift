import SwiftUI

struct InventoryCardView: View {
    let title: String
    let subtitle: String?
    let quantity: Int
    let category: InventoryImageCategory

    var body: some View {
        HStack(spacing: 14) {
            InventoryCardImageView(name: subtitle ?? title, category: category)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                if let subtitle, !subtitle.isEmpty, subtitle != title {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Text("×\(quantity)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.accentSoft)
                .clipShape(Capsule())
        }
        .padding(14)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct InventoryCardImageView: View {
    let name: String
    let category: InventoryImageCategory

    var body: some View {
        Group {
            if let image = InventoryImageResolver.shared.loadImage(named: name, category: category) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.cardBorder)

                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
