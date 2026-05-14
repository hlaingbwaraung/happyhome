import Foundation

enum SupabaseConfig {
    static let projectURL = "https://qgjtigceyvangrsshxwg.supabase.co"
    static let anonKey = "sb_publishable_EK0EZIIF-6pQlCWQh-39kQ_ACDEZRcn"

    static var isConfigured: Bool {
        projectURL.contains(".supabase.co") &&
        !projectURL.contains("YOUR_PROJECT_REF") &&
        !anonKey.contains("YOUR_SUPABASE") &&
        !anonKey.isEmpty
    }
}
