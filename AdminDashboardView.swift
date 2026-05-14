import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

struct AdminDashboardView: View {
    @EnvironmentObject private var propertyStore: PropertyStore

    let language: AppLanguage

    @State private var draftProperty = Property.blank
    @State private var isShowingEditor = false

    var body: some View {
        List {
            Section {
                Button {
                    draftProperty = .blank
                    isShowingEditor = true
                } label: {
                    Label("Add Apartment", systemImage: "plus.circle.fill")
                }

                Button(role: .destructive) {
                    propertyStore.resetToSamples()
                } label: {
                    Label("Reset Sample Apartments", systemImage: "arrow.counterclockwise")
                }
            }

            Section("Apartments") {
                ForEach(propertyStore.properties) { property in
                    HStack(spacing: 12) {
                        PropertyImageView(property: property, height: 52)
                            .frame(width: 64, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(property.title(in: language).isEmpty ? "Untitled Apartment" : property.title(in: language))
                                .font(.headline)

                            Text("\(property.category.rawValue) · \(property.area) · ¥\(property.price)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(property.isAvailable ? "Available" : "Hidden from users")
                                .font(.caption)
                                .foregroundStyle(property.isAvailable ? .green : .secondary)
                        }

                        Spacer()

                        Button {
                            draftProperty = property
                            isShowingEditor = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            propertyStore.delete(property)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Admin Dashboard")
        .sheet(isPresented: $isShowingEditor) {
            PropertyEditorView(property: $draftProperty) { savedProperty in
                if propertyStore.properties.contains(where: { $0.id == savedProperty.id }) {
                    propertyStore.update(savedProperty)
                } else {
                    propertyStore.add(savedProperty)
                }

                isShowingEditor = false
            } onCancel: {
                isShowingEditor = false
            }
        }
    }
}

struct PropertyEditorView: View {
    @Binding var property: Property

    let onSave: (Property) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(property.titleEnglish.isEmpty ? "Apartment Details" : property.titleEnglish)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Cancel", action: onCancel)

                Button("Save") {
                    onSave(property)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
            .padding()

            Divider()

            Form {
                Section("Basic") {
                    Picker("Category", selection: $property.category) {
                        ForEach(PropertyCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }

                    Toggle("Show to users", isOn: $property.isAvailable)
                    TextField("Area", text: $property.area)
                    TextField("Station", text: $property.station)
                    TextField("Room type", text: $property.roomType)
                    TextField("Size", text: $property.size)
                    TextField("Price", value: $property.price, format: .number)
                }

                Section("Titles") {
                    TextField("Japanese title", text: $property.titleJapanese)
                    TextField("English title", text: $property.titleEnglish)
                    TextField("Myanmar title", text: $property.titleMyanmar)
                }

                Section("Descriptions") {
                    TextField("Japanese description", text: $property.descriptionJapanese, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("English description", text: $property.descriptionEnglish, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Myanmar description", text: $property.descriptionMyanmar, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Photo And Extra Features") {
                    HStack(spacing: 12) {
                        PropertyImageView(property: property, height: 92)
                            .frame(width: 120, height: 92)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 8) {
                            Button {
                                choosePhoto()
                            } label: {
                                Label("Choose Photo", systemImage: "photo")
                            }

                            TextField("Photo file path", text: $property.photoPath)
                            TextField("Fallback symbol name", text: $property.imageName)
                        }
                    }

                    TextField("External listing URL", text: $property.externalURL)
                    TextField("Features, separated by commas", text: $property.features, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .formStyle(.grouped)
            .padding()
        }
        .frame(width: 720, height: 760)
    }

    private var canSave: Bool {
        !property.titleEnglish.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !property.area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func choosePhoto() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]

        if panel.runModal() == .OK, let url = panel.url {
            property.photoPath = url.path
        }
        #endif
    }
}

#if canImport(PreviewsMacros)
#Preview {
    NavigationStack {
        AdminDashboardView(language: .english)
            .environmentObject(PropertyStore())
    }
}
#endif
