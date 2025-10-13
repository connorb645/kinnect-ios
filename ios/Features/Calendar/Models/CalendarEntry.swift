import Foundation

/// A simple calendar entry with a title, description, and time range.
public struct CalendarEntry: Identifiable {
    public typealias ID = UUID
    public let id: ID
    public var title: String
    public var eventDescription: String?
    public var startDate: Date
    public var endDate: Date

    public init(
        id: ID = UUID(),
        title: String,
        eventDescription: String? = nil,
        startDate: Date,
        endDate: Date
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.startDate = startDate
        self.endDate = endDate
    }
}
