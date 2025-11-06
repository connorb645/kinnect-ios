import Foundation

enum CalendarFormatters {
  static let monthHeader: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "LLLL yyyy"
    return df
  }()

  static let monthShort: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "LLL"
    return df
  }()

  static let monthShortYear: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "LLL yyyy"
    return df
  }()

  static let dayFull: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .none
    return df
  }()

  static let timeShort: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .none
    df.timeStyle = .short
    return df
  }()
}
