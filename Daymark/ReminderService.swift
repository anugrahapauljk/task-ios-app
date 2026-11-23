import Foundation
import UserNotifications

@MainActor
enum ReminderService {
    static func schedule(_ task: TaskItem) async -> Bool {
        guard task.reminderEnabled, !task.isCompleted,
              let dueAt = task.dueAt, dueAt > .now else { return false }

        let center = UNUserNotificationCenter.current()
        var settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            settings = await center.notificationSettings()
        }

        guard settings.authorizationStatus == .authorized ||
                settings.authorizationStatus == .provisional ||
                settings.authorizationStatus == .ephemeral else { return false }

        let content = UNMutableNotificationContent()
        content.title = "A moment for your day"
        content.body = task.title
        content.sound = .default
        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueAt)
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        )
        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    static func cancel(_ id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
