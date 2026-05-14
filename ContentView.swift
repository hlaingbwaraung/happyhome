import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var selectedLanguage: AppLanguage = .japanese

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    languageSelector

                    VStack(spacing: 14) {
                        NavigationLink {
                            PropertyListView(category: .rent, language: selectedLanguage)
                        } label: {
                            HomeButton(
                                title: PropertyCategory.rent.title(in: selectedLanguage),
                                subtitle: PropertyCategory.rent.subtitle(in: selectedLanguage),
                                icon: "house.fill"
                            )
                        }

                        NavigationLink {
                            PropertyListView(category: .buy, language: selectedLanguage)
                        } label: {
                            HomeButton(
                                title: PropertyCategory.buy.title(in: selectedLanguage),
                                subtitle: PropertyCategory.buy.subtitle(in: selectedLanguage),
                                icon: "building.2.fill"
                            )
                        }

                        NavigationLink {
                            KnowledgeView(language: selectedLanguage)
                        } label: {
                            HomeButton(title: knowledgeTitle, subtitle: knowledgeSubtitle, icon: "book.fill")
                        }

                        if authManager.signedInAccount?.role == .admin {
                            NavigationLink {
                                AdminDashboardView(language: selectedLanguage)
                            } label: {
                                HomeButton(title: "Admin Dashboard", subtitle: "Add, edit, delete apartments", icon: "slider.horizontal.3")
                            }
                        }
                    }

                    contactCard
                }
                .padding()
            }
            .background(pageBackground)
            .navigationTitle("Happy Home")
        }
    }

    private var heroMessage: String {
        switch selectedLanguage {
        case .japanese: return "全物件外国人入居可能"
        case .english: return "All properties available for foreign residents"
        case .myanmar: return "အိမ်ခြံမြေအားလုံး နိုင်ငံခြားသားများ နေထိုင်နိုင်ပါသည်"
        }
    }

    private var heroSubtitle: String {
        switch selectedLanguage {
        case .japanese: return "外国人のお客様も安心してご相談ください"
        case .english: return "Real estate support in Japan for foreign residents"
        case .myanmar: return "ဂျပန်တွင် နိုင်ငံခြားသားများအတွက် အိမ်ခြံမြေကူညီမှု"
        }
    }

    private var knowledgeTitle: String {
        switch selectedLanguage {
        case .japanese: return "知識"
        case .english: return "Knowledge"
        case .myanmar: return "ဗဟုသုတ"
        }
    }

    private var knowledgeSubtitle: String {
        switch selectedLanguage {
        case .japanese: return "Knowledge"
        case .english: return "Resident guide"
        case .myanmar: return "နေထိုင်မှုလမ်းညွှန်"
        }
    }

    private var callText: String {
        switch selectedLanguage {
        case .japanese: return "電話 03-5834-8531"
        case .english: return "Call 03-5834-8531"
        case .myanmar: return "ဖုန်းခေါ်ရန် 03-5834-8531"
        }
    }

    private var pageBackground: Color {
        #if os(iOS)
        Color(.systemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(.secondarySystemBackground)
        #endif
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("Happy Home")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("REAL ESTATE AGENT")
                .font(.caption)
                .tracking(2)
                .foregroundStyle(.secondary)

            Text(heroMessage)
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(heroSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 16)
    }

    private var languageSelector: some View {
        HStack {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    selectedLanguage = language
                } label: {
                    Text(language.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(selectedLanguage == language ? Color.yellow : Color.white)
                        .foregroundStyle(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var contactCard: some View {
        VStack(spacing: 8) {
            Text("株式会社Happy Home")
                .font(.headline)

            Text("〒114-0015 東京都北区中里1-3-3 アオヤマビル4階")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Link(callText, destination: URL(string: "tel:0358348531")!)
                .font(.headline)
                .padding(.top, 6)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct HomeButton: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color.yellow)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .foregroundStyle(.black)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#if canImport(PreviewsMacros)
#Preview {
    ContentView()
}
#endif
