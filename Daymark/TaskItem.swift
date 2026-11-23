import Foundation

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var day: Date
    var dueAt: Date?
    var reminderEnabled: Bool
    var isCompleted: Bool = false
    var createdAt: Date = .now
}
