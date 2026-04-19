import SwiftUI

struct DeviceRowView: View {
    let device: Device

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(device.status == "online" ? .green : .gray)
                    .frame(width: 10, height: 10)

                Text(device.name)
                    .font(.headline)

                Spacer()

                Text(device.status.capitalized)
                    .foregroundStyle(device.status == "online" ? .green : .secondary)
            }

            Text("Platform: \(device.platform)")
                .font(.subheadline)

            Text("Agent version: \(device.agentVersion)")
                .font(.subheadline)

            Text(lastSeenText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var lastSeenText: String {
        guard let lastSeenAt = device.lastSeenAt else {
            return "Never seen"
        }

        return "Last seen: \(lastSeenAt)"
    }
}
