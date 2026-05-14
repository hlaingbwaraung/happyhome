import SwiftUI

struct PropertyListView: View {
    @EnvironmentObject private var propertyStore: PropertyStore

    let category: PropertyCategory
    let language: AppLanguage

    @State private var searchText = ""
    @State private var selectedRoomType = "All"

    private let roomTypes = ["All", "1K", "1LDK", "2DK", "2LDK"]

    private var filteredProperties: [Property] {
        propertyStore.properties.filter { property in
            property.category == category &&
            property.isAvailable &&
            (searchText.isEmpty ||
             property.title(in: language).localizedCaseInsensitiveContains(searchText) ||
             property.area.localizedCaseInsensitiveContains(searchText) ||
             property.station.localizedCaseInsensitiveContains(searchText)) &&
            (selectedRoomType == "All" || property.roomType == selectedRoomType)
        }
    }

    private var roomTypeLabel: String {
        switch language {
        case .japanese: return "間取り"
        case .english: return "Room Type"
        case .myanmar: return "အခန်းအမျိုးအစား"
        }
    }

    private var searchPrompt: String {
        switch language {
        case .japanese: return "エリアまたは駅を検索"
        case .english: return "Search area or station"
        case .myanmar: return "ဧရိယာ သို့မဟုတ် ဘူတာရှာရန်"
        }
    }

    var body: some View {
        List {
            Section {
                Picker(roomTypeLabel, selection: $selectedRoomType) {
                    ForEach(roomTypes, id: \.self) { roomType in
                        Text(roomType)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                ForEach(filteredProperties) { property in
                    NavigationLink {
                        PropertyDetailView(property: property, language: language)
                    } label: {
                        PropertyRow(property: property, language: language)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: searchPrompt)
        .navigationTitle(category.title(in: language))
    }
}

struct PropertyRow: View {
    let property: Property
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 14) {
            PropertyImageView(property: property, height: 56)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(property.title(in: language))
                    .font(.headline)

                Text("\(property.area) · \(property.station)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(priceText)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if !property.features.isEmpty {
                    Text(property.features)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 6)
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
}

#if canImport(PreviewsMacros)
#Preview {
    NavigationStack {
        PropertyListView(category: .rent, language: .english)
            .environmentObject(PropertyStore())
    }
}
#endif
