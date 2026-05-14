import Foundation

@MainActor
final class PropertyStore: ObservableObject {
    @Published private(set) var properties: [Property] = []

    private let storageKey = "happyhome.properties"

    init() {
        load()
    }

    func add(_ property: Property) {
        properties.insert(property, at: 0)
        save()
    }

    func update(_ property: Property) {
        guard let index = properties.firstIndex(where: { $0.id == property.id }) else {
            return
        }

        properties[index] = property
        save()
    }

    func delete(_ property: Property) {
        properties.removeAll { $0.id == property.id }
        save()
    }

    func resetToSamples() {
        properties = sampleProperties
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let savedProperties = try? JSONDecoder().decode([Property].self, from: data) else {
            properties = sampleProperties
            save()
            return
        }

        properties = savedProperties
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(properties) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
