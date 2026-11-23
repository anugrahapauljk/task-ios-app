import Foundation
import Combine

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var notice: String?

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        fileURL = support.appendingPathComponent("Daymark", isDirectory: true)
            .appendingPathComponent("tasks.json")
        load()
        refresh()
    }

    func tasks(on day: Date) -> [TaskItem] {
        tasks.filter { Calendar.current.isDate($0.day, inSameDayAs: day) }
            .sorted {
                if $0.isCompleted != $1.isCompleted { return !$0.isCompleted }
                switch ($0.dueAt, $1.dueAt) {
                case let (left?, right?): return left < right
                case (_?, nil): return true
                case (nil, _?): return false
                default: return $0.createdAt < $1.createdAt
                }
            }
    }

    func add(title: String, dueAt: Date?, reminderEnabled: Bool) {
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        let item = TaskItem(title: cleaned, day: Calendar.current.startOfDay(for: .now),
                            dueAt: dueAt, reminderEnabled: reminderEnabled && dueAt != nil)
        tasks.append(item)
        save()
        if item.reminderEnabled {
            Task {
                if !(await ReminderService.schedule(item)) {
                    notice = "Reminder unavailable. Check notification permission in Settings."
                }
            }
        }
    }

    func toggle(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
        let item = tasks[index]
        save()
        if item.isCompleted {
            ReminderService.cancel(id)
        } else if item.reminderEnabled, let dueAt = item.dueAt, dueAt > .now {
            Task { _ = await ReminderService.schedule(item) }
        }
    }

    func delete(_ id: UUID) {
        tasks.removeAll { $0.id == id }
        ReminderService.cancel(id)
        save()
    }

    func refresh() {
        let today = Calendar.current.startOfDay(for: .now)
        let oldest = Calendar.current.date(byAdding: .day, value: -6, to: today)!
        let expired = tasks.filter { $0.day < oldest || $0.day > today }
        guard !expired.isEmpty else { return }
        expired.forEach { ReminderService.cancel($0.id) }
        tasks.removeAll { $0.day < oldest || $0.day > today }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            notice = "Saved tasks could not be opened."
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try JSONEncoder().encode(tasks).write(to: fileURL, options: .atomic)
        } catch {
            notice = "Tasks could not be saved on this device."
        }
    }
}
