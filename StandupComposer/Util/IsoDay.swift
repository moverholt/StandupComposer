//
//  IsoDay.swift
//  JWTMenu
//
//  Created by Matt Overholt on 12/19/25.
//

import Foundation

func splitIsoDayStr(_ str: String) -> (Int, Int, Int) {
    let parts = str.split(separator: "-").map { String($0) }
    if parts.count == 3,
       let year = Int(parts[0]),
       let month = Int(parts[1]),
       let day = Int(parts[2]) {
        return (year, month, day)
    }
    fatalError("IsoDay could not parse string: \(str)")
}

struct IsoDay: Identifiable, CustomStringConvertible, Codable, Equatable, Comparable, Hashable {
    let year: Int
    let month: Int
    let day: Int
    
    init() {
        let now = Date()
        self.init(now.isoComponents)
    }
    
    init (_ year: Int, _ month: Int, _ day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    init(_ args: (year: Int, month: Int, day: Int)) {
        self.year = args.year
        self.month = args.month
        self.day = args.day
    }
    
    init(_ str: String) {
        let (year, month, day) = splitIsoDayStr(str)
        self.year = year
        self.month = month
        self.day = day
    }
    
    static func == (lhs: IsoDay, rhs: IsoDay) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
    
    static func < (lhs: IsoDay, rhs: IsoDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
    
    var description: String {
        formatted
    }
    
    var formatted: String {
        // "\(year)-\(month)-\(day)"
        String(format: "%04d-%02d-%02d", year, month, day)
    }
    
    func formatted(style: Date.FormatStyle.DateStyle) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }

    var sectionHeaderTitle: String {
        if self == IsoDay.today { return "Today" }
        if self == IsoDay.yesterday { return "Yesterday" }
        return formatted(style: .complete)
    }

    var id: String {
        description
    }
    
    static var today: IsoDay {
        IsoDay()
    }
    
    static var tomorrow: IsoDay {
        IsoDay.today.addDays(1)
    }
    
    static var yesterday: IsoDay {
        IsoDay.today.subDays(1)
    }
    
    func addDays(_ days: Int) -> IsoDay {
        Calendar.current.date(byAdding: .day, value: days, to: self.date)!.isoDay
    }
    
    func subDays(_ days: Int) -> IsoDay {
        addDays(-days)
    }
    
    func subWeeks(_ weeks: Int) -> IsoDay {
        addDays(-7 * weeks)
    }
    
    var date: Date {
        Calendar.current.date(
            from: DateComponents(year: year, month: month, day: day)
        )!
    }
    
    var isMonday: Bool {
        Calendar.current.component(.weekday, from: date) == 2
    }
    
    var thisWeekMonday: IsoDay {
        var d = self
        while d.isMonday == false {
            print("d: \(d)")
            d = d.subDays(1)
        }
        return d
    }
    
    var start: Date {
        Calendar.current.startOfDay(for: self.date)
    }
    
    var end: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        
        let parts = str.split(separator: "-").map { String($0) }
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "IsoDay string must be in format YYYY-MM-DD, got: \(str)"
            )
        }
        
        self.year = year
        self.month = month
        self.day = day
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(formatted)
    }
}

extension Date {
    var isoComponents: (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        return (year, month, day)
    }
    
    var isoDay: IsoDay {
        return IsoDay(self.isoComponents)
    }
}
