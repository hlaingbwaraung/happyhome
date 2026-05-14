import SwiftUI

struct KnowledgeView: View {
    let language: AppLanguage

    private var sectionTitle: String {
        switch language {
        case .japanese: return "外国人入居者向け"
        case .english: return "For Foreign Residents"
        case .myanmar: return "နိုင်ငံခြားသားနေထိုင်သူများအတွက်"
        }
    }

    private var navigationTitle: String {
        switch language {
        case .japanese: return "知識"
        case .english: return "Knowledge"
        case .myanmar: return "ဗဟုသုတ"
        }
    }

    private var callTitle: String {
        switch language {
        case .japanese: return "電話 03-5834-8531"
        case .english: return "Call 03-5834-8531"
        case .myanmar: return "ဖုန်းခေါ်ရန် 03-5834-8531"
        }
    }

    private var rows: [(title: String, text: String)] {
        switch language {
        case .japanese:
            return [
                ("必要書類", "在留カード、パスポート、緊急連絡先、収入証明、電話番号などが必要になる場合があります。"),
                ("初期費用", "敷金、礼金、仲介手数料、保証会社費用、保険料、前家賃などがかかる場合があります。"),
                ("保証会社", "多くの賃貸物件では、個人保証人の代わりに保証会社の利用が必要です。"),
                ("Happy Homeへ相談", "Happy Homeは、日本で賃貸や購入を希望する外国人のお客様をサポートします。")
            ]
        case .english:
            return [
                ("Documents Needed", "Residence card, passport, emergency contact, proof of income, and phone number may be required."),
                ("Initial Cost", "Initial cost may include deposit, key money, agency fee, guarantor fee, insurance, and first month rent."),
                ("Guarantor Company", "Many rental properties require a guarantor company instead of a personal guarantor."),
                ("Contact Happy Home", "Happy Home can help foreign residents find rental and purchase properties in Japan.")
            ]
        case .myanmar:
            return [
                ("လိုအပ်သောစာရွက်စာတမ်းများ", "နေထိုင်ခွင့်ကတ်၊ ပတ်စ်ပို့၊ အရေးပေါ်ဆက်သွယ်ရန်၊ ဝင်ငွေအထောက်အထားနှင့် ဖုန်းနံပါတ် လိုအပ်နိုင်ပါသည်။"),
                ("အစပိုင်းကုန်ကျစရိတ်", "Deposit၊ key money၊ အေဂျင်စီခ၊ အာမခံကုမ္ပဏီခ၊ အာမခံကြေးနှင့် ပထမလအိမ်ငှားခ ပါဝင်နိုင်ပါသည်။"),
                ("အာမခံကုမ္ပဏီ", "အငှားအိမ်အများစုတွင် ကိုယ်ပိုင်အာမခံသူအစား အာမခံကုမ္ပဏီ အသုံးပြုရန် လိုအပ်ပါသည်။"),
                ("Happy Home သို့ ဆက်သွယ်ရန်", "Happy Home သည် ဂျပန်တွင် အိမ်ငှားရန် သို့မဟုတ် ဝယ်ရန် နိုင်ငံခြားသားများကို ကူညီပေးပါသည်။")
            ]
        }
    }

    var body: some View {
        List {
            Section(sectionTitle) {
                ForEach(rows, id: \.title) { row in
                    KnowledgeRow(title: row.title, text: row.text)
                }
            }

            Section {
                Link(destination: URL(string: "tel:0358348531")!) {
                    Label(callTitle, systemImage: "phone.fill")
                }
            }
        }
        .navigationTitle(navigationTitle)
    }
}

struct KnowledgeRow: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
    }
}

#if canImport(PreviewsMacros)
#Preview {
    NavigationStack {
        KnowledgeView(language: .english)
    }
}
#endif
