import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case japanese = "日本語"
    case english = "English"
    case myanmar = "Myanmar"

    var id: String { rawValue }
}

enum PropertyCategory: String, CaseIterable, Identifiable, Codable {
    case rent = "Rent"
    case buy = "Buy"

    var id: String { rawValue }

    func title(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.rent, .japanese): return "賃貸"
        case (.rent, .english): return "Rent"
        case (.rent, .myanmar): return "ငှားရန်"
        case (.buy, .japanese): return "売買"
        case (.buy, .english): return "Buy"
        case (.buy, .myanmar): return "ဝယ်ရန်"
        }
    }

    func subtitle(in language: AppLanguage) -> String {
        switch (self, language) {
        case (.rent, .japanese): return "Rent"
        case (.rent, .english): return "Rental properties"
        case (.rent, .myanmar): return "အိမ်ခန်းငှား"
        case (.buy, .japanese): return "Buy"
        case (.buy, .english): return "Properties for sale"
        case (.buy, .myanmar): return "အိမ်ခြံမြေဝယ်ယူ"
        }
    }
}

struct Property: Identifiable, Codable, Equatable {
    var id = UUID()
    var titleJapanese: String
    var titleEnglish: String
    var titleMyanmar: String
    var category: PropertyCategory
    var area: String
    var station: String
    var price: Int
    var roomType: String
    var size: String
    var descriptionJapanese: String
    var descriptionEnglish: String
    var descriptionMyanmar: String
    var imageName: String
    var photoPath: String
    var externalURL: String
    var features: String
    var isAvailable: Bool

    func title(in language: AppLanguage) -> String {
        switch language {
        case .japanese: return titleJapanese
        case .english: return titleEnglish
        case .myanmar: return titleMyanmar
        }
    }

    func description(in language: AppLanguage) -> String {
        switch language {
        case .japanese: return descriptionJapanese
        case .english: return descriptionEnglish
        case .myanmar: return descriptionMyanmar
        }
    }

    static var blank: Property {
        Property(
            titleJapanese: "",
            titleEnglish: "",
            titleMyanmar: "",
            category: .rent,
            area: "",
            station: "",
            price: 0,
            roomType: "",
            size: "",
            descriptionJapanese: "",
            descriptionEnglish: "",
            descriptionMyanmar: "",
            imageName: "house",
            photoPath: "",
            externalURL: "",
            features: "",
            isAvailable: true
        )
    }
}

let sampleProperties: [Property] = [
    Property(
        titleJapanese: "駒込 1K アパート",
        titleEnglish: "Komagome 1K Apartment",
        titleMyanmar: "ကိုမာဂိုမဲ 1K အခန်း",
        category: .rent,
        area: "Kita-ku",
        station: "Komagome Station",
        price: 85000,
        roomType: "1K",
        size: "25㎡",
        descriptionJapanese: "駅近のきれいなアパートです。外国人入居可能で、学生や社会人におすすめです。",
        descriptionEnglish: "A clean apartment near the station. Foreigner-friendly and suitable for students or workers.",
        descriptionMyanmar: "ဘူတာအနီးရှိ သန့်ရှင်းသောအခန်းပါ။ နိုင်ငံခြားသားများနေထိုင်နိုင်ပြီး ကျောင်းသားနှင့် အလုပ်သမားများအတွက် သင့်တော်ပါသည်။",
        imageName: "house",
        photoPath: "",
        externalURL: "",
        features: "Foreigner-friendly, Near station, Student OK",
        isAvailable: true
    ),
    Property(
        titleJapanese: "田端 ファミリールーム",
        titleEnglish: "Tabata Family Room",
        titleMyanmar: "တာဘာတာ မိသားစုအခန်း",
        category: .rent,
        area: "Kita-ku",
        station: "Tabata Station",
        price: 125000,
        roomType: "2DK",
        size: "42㎡",
        descriptionJapanese: "都心へのアクセスが便利な、家族向けの賃貸物件です。",
        descriptionEnglish: "Comfortable family-size rental property with convenient access to central Tokyo.",
        descriptionMyanmar: "တိုကျိုမြို့လယ်သို့ သွားလာရလွယ်ကူသော မိသားစုနေထိုင်ရန် သင့်တော်သည့် အငှားအခန်းပါ။",
        imageName: "building",
        photoPath: "",
        externalURL: "",
        features: "Family-friendly, Good access, Quiet area",
        isAvailable: true
    ),
    Property(
        titleJapanese: "巣鴨 コンパクトマンション",
        titleEnglish: "Sugamo Compact Condo",
        titleMyanmar: "ဆူဂါမို ကွန်ဒိုအခန်း",
        category: .buy,
        area: "Toshima-ku",
        station: "Sugamo Station",
        price: 29800000,
        roomType: "1LDK",
        size: "38㎡",
        descriptionJapanese: "購入向けのコンパクトなマンションです。買い物や交通に便利な立地です。",
        descriptionEnglish: "A compact condominium for purchase. Good location and easy access to shops and transport.",
        descriptionMyanmar: "ဝယ်ယူရန် သင့်တော်သော ကွန်ဒိုအခန်းပါ။ စျေးဝယ်ခြင်းနှင့် သွားလာရေးအတွက် နေရာကောင်းပါသည်။",
        imageName: "building.2",
        photoPath: "",
        externalURL: "",
        features: "Condo, Shopping nearby, Good transport",
        isAvailable: true
    ),
    Property(
        titleJapanese: "赤羽 投資向けルーム",
        titleEnglish: "Akabane Investment Room",
        titleMyanmar: "အာကာဘာနဲ ရင်းနှီးမြှုပ်နှံမှုအခန်း",
        category: .buy,
        area: "Kita-ku",
        station: "Akabane Station",
        price: 36500000,
        roomType: "2LDK",
        size: "55㎡",
        descriptionJapanese: "居住にも投資にも向いている明るい物件です。外国人入居の相談も可能です。",
        descriptionEnglish: "A bright property suitable for living or investment. Foreign resident consultation available.",
        descriptionMyanmar: "နေထိုင်ရန် သို့မဟုတ် ရင်းနှီးမြှုပ်နှံရန် သင့်တော်သော အလင်းရောင်ကောင်းသည့်အခန်းပါ။ နိုင်ငံခြားသားနေထိုင်မှုအတွက် ဆွေးနွေးနိုင်ပါသည်။",
        imageName: "house.lodge",
        photoPath: "",
        externalURL: "",
        features: "Investment, Bright room, Consultation available",
        isAvailable: true
    )
]
