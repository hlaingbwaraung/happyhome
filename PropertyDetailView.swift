import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    let language: AppLanguage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PropertyImageView(property: property, height: 220)

                VStack(alignment: .leading, spacing: 14) {
                    Text(property.title(in: language))
                        .font(.title)
                        .fontWeight(.bold)

                    Text(priceText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)

                    detailRow(title: areaLabel, value: property.area)
                    detailRow(title: stationLabel, value: property.station)
                    detailRow(title: roomTypeLabel, value: property.roomType)
                    detailRow(title: sizeLabel, value: property.size)

                    if !property.features.isEmpty {
                        detailRow(title: "Features", value: property.features)
                    }

                    Divider()

                    Text(descriptionLabel)
                        .font(.headline)

                    Text(property.description(in: language))
                        .font(.body)
                        .foregroundStyle(.secondary)

                    if let externalURL {
                        Link(destination: externalURL) {
                            Label("Open external listing", systemImage: "arrow.up.right.square")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Link(destination: URL(string: "tel:0358348531")!) {
                        Label(callLabel, systemImage: "phone.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundStyle(.yellow)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle(detailTitle)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var detailTitle: String {
        switch language {
        case .japanese: return "物件詳細"
        case .english: return "Property Detail"
        case .myanmar: return "အိမ်ခြံမြေအသေးစိတ်"
        }
    }

    private var areaLabel: String {
        switch language {
        case .japanese: return "エリア"
        case .english: return "Area"
        case .myanmar: return "ဧရိယာ"
        }
    }

    private var stationLabel: String {
        switch language {
        case .japanese: return "最寄り駅"
        case .english: return "Station"
        case .myanmar: return "ဘူတာ"
        }
    }

    private var roomTypeLabel: String {
        switch language {
        case .japanese: return "間取り"
        case .english: return "Room Type"
        case .myanmar: return "အခန်းအမျိုးအစား"
        }
    }

    private var sizeLabel: String {
        switch language {
        case .japanese: return "広さ"
        case .english: return "Size"
        case .myanmar: return "အကျယ်အဝန်း"
        }
    }

    private var descriptionLabel: String {
        switch language {
        case .japanese: return "説明"
        case .english: return "Description"
        case .myanmar: return "ဖော်ပြချက်"
        }
    }

    private var callLabel: String {
        switch language {
        case .japanese: return "Happy Homeへ電話"
        case .english: return "Call Happy Home"
        case .myanmar: return "Happy Home သို့ ဖုန်းခေါ်ရန်"
        }
    }

    private var priceText: String {
        if property.category == .rent {
            switch language {
            case .japanese: return "¥\(property.price) / 月"
            case .english: return "¥\(property.price) / month"
            case .myanmar: return "¥\(property.price) / လ"
            }
        } else {
            return "¥\(property.price)"
        }
    }

    private var externalURL: URL? {
        guard !property.externalURL.isEmpty else {
            return nil
        }

        return URL(string: property.externalURL)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#if canImport(PreviewsMacros)
#Preview {
    NavigationStack {
        PropertyDetailView(property: sampleProperties[0], language: .english)
    }
}
#endif
