import Foundation

final class PhotoFormatter {
    static func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    static func stringToDate(dateString: String) -> Date? {
        let iso8601DateFormatter = ISO8601DateFormatter()
        
        return iso8601DateFormatter.date(from: dateString)
    }
}
