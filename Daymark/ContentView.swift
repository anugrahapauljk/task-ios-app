import SwiftUI

enum DaymarkStyle {
    static let background = Color(red: 0.055, green: 0.071, blue: 0.105)
    static let panel = Color(red: 0.105, green: 0.129, blue: 0.176)
    static let panelLight = Color(red: 0.149, green: 0.176, blue: 0.224)
    static let cream = Color(red: 0.987, green: 0.950, blue: 0.870)
    static let muted = Color(red: 0.602, green: 0.637, blue: 0.682)
    static let coral = Color(red: 1.000, green: 0.552, blue: 0.444)
    static let lilac = Color(red: 0.745, green: 0.678, blue: 0.970)
    static let mint = Color(red: 0.632, green: 0.867, blue: 0.737)
}

struct ContentView: View {
    @StateObject private var store = TaskStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var today = Calendar.current.startOfDay(for: .now)
    @State private var selectedDay = Calendar.current.startOfDay(for: .now)
    @State private var showingNewTask = false
    @State private var showingNotice = false

    private var dayTasks: [TaskItem] { store.tasks(on: selectedDay) }
    private var completedCount: Int { dayTasks.filter(\.isCompleted).count }
    private var isToday: Bool { Calendar.current.isDate(selectedDay, inSameDayAs: today) }

    var body: some View {
        ZStack {
            DaymarkStyle.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    header
                    daySelector
                    progressCard
                    taskSection
                    Text("A little progress is still progress.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(DaymarkStyle.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isToday {
                Button {
                    showingNewTask = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .bold))
                        Text("Add a task")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(DaymarkStyle.background)
                    .padding(.horizontal, 22)
                    .frame(height: 58)
                    .background(DaymarkStyle.coral, in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(DaymarkStyle.background.opacity(0.97))
            }
        }
        .sheet(isPresented: $showingNewTask) {
            NewTaskView { title, dueAt, reminderEnabled in
                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                    store.add(title: title, dueAt: dueAt, reminderEnabled: reminderEnabled)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            updateDay()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { updateDay() }
        }
        .onChange(of: store.notice) { _, newValue in
            showingNotice = newValue != nil
        }
        .alert("Daymark", isPresented: $showingNotice) {
            Button("OK") { store.notice = nil }
        } message: {
            Text(store.notice ?? "")
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                HStack(spacing: 9) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 19))
                        .foregroundStyle(DaymarkStyle.coral)
                    Text("DAYMARK")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(DaymarkStyle.cream)
                }
                Spacer()
                Text("YOUR DAILY SPACE")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(DaymarkStyle.muted)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(isToday ? "Make today" : selectedDay.formatted(.dateTime.weekday(.wide)))
                    .foregroundStyle(DaymarkStyle.cream)
                + Text(isToday ? " yours." : " in review.")
                    .foregroundStyle(DaymarkStyle.coral)
            }
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .tracking(-1.8)
            .minimumScaleFactor(0.72)
            .lineLimit(1)

            Text(selectedDay.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(DaymarkStyle.muted)
        }
    }

    private var daySelector: some View {
        HStack(spacing: 7) {
            ForEach((0..<7).reversed(), id: \.self) { offset in
                let day = Calendar.current.date(byAdding: .day, value: -offset, to: today)!
                let selected = Calendar.current.isDate(day, inSameDayAs: selectedDay)
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { selectedDay = day }
                } label: {
                    VStack(spacing: 9) {
                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(selected ? DaymarkStyle.background : DaymarkStyle.muted)
                        Text(day.formatted(.dateTime.day()))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(selected ? DaymarkStyle.background : DaymarkStyle.cream)
                        Circle()
                            .fill(selected ? DaymarkStyle.background : (store.tasks(on: day).isEmpty ? .clear : DaymarkStyle.coral))
                            .frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 75)
                    .background(selected ? DaymarkStyle.cream : DaymarkStyle.panel,
                                in: RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
            }
        }
    }

    private var progressCard: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 7) {
                    Circle().fill(DaymarkStyle.mint).frame(width: 7, height: 7)
                    Text(isToday ? "TODAY'S FLOW" : "DAY'S FLOW")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(DaymarkStyle.mint)
                }
                Text(dayTasks.isEmpty ? "A clean slate" : "Keep the rhythm")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(DaymarkStyle.cream)
                Text(dayTasks.isEmpty ? "Your next step starts here." : "\(completedCount) of \(dayTasks.count) tasks complete")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(DaymarkStyle.muted)
            }
            Spacer(minLength: 4)
            ZStack {
                Circle().stroke(DaymarkStyle.panelLight, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: dayTasks.isEmpty ? 0 : CGFloat(completedCount) / CGFloat(dayTasks.count))
                    .stroke(DaymarkStyle.mint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: completedCount)
                Text(dayTasks.isEmpty ? "—" : "\(Int(Double(completedCount) / Double(dayTasks.count) * 100))%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(DaymarkStyle.cream)
            }
            .frame(width: 72, height: 72)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [DaymarkStyle.panelLight, DaymarkStyle.panel],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26)
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .stroke(DaymarkStyle.lilac.opacity(0.12), lineWidth: 1)
                .frame(width: 120, height: 120)
                .offset(x: 45, y: -45)
                .clipped()
        }
    }

    private var taskSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(isToday ? "The little things" : "That day's tasks")
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .foregroundStyle(DaymarkStyle.cream)
                Spacer()
                Text("\(dayTasks.count) TASK\(dayTasks.count == 1 ? "" : "S")")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(DaymarkStyle.muted)
            }

            if dayTasks.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 27, weight: .light))
                        .foregroundStyle(DaymarkStyle.lilac)
                    Text(isToday ? "What will you do today?" : "No tasks were added this day")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(DaymarkStyle.cream)
                    if isToday {
                        Text("Tap Add a task to begin.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(DaymarkStyle.muted)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 38)
                .background(DaymarkStyle.panel, in: RoundedRectangle(cornerRadius: 24))
            } else {
                VStack(spacing: 10) {
                    ForEach(dayTasks) { item in
                        TaskRow(item: item,
                                onToggle: { withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) { store.toggle(item.id) } },
                                onDelete: { withAnimation { store.delete(item.id) } })
                    }
                }
            }
        }
    }

    private func updateDay() {
        let current = Calendar.current.startOfDay(for: .now)
        if current != today {
            today = current
            selectedDay = current
        }
        store.refresh()
    }
}

private struct TaskRow: View {
    let item: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 27, weight: .light))
                    .foregroundStyle(item.isCompleted ? DaymarkStyle.mint : DaymarkStyle.lilac)
                    .symbolEffect(.bounce, value: item.isCompleted)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isCompleted ? "Mark \(item.title) incomplete" : "Complete \(item.title)")

            VStack(alignment: .leading, spacing: 7) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(item.isCompleted ? DaymarkStyle.muted : DaymarkStyle.cream)
                    .strikethrough(item.isCompleted, color: DaymarkStyle.muted)
                if let dueAt = item.dueAt {
                    HStack(spacing: 5) {
                        Image(systemName: item.reminderEnabled ? "bell.fill" : "clock")
                        Text(dueAt.formatted(date: .omitted, time: .shortened))
                    }
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(item.isCompleted ? DaymarkStyle.muted : DaymarkStyle.lilac)
                }
            }
            Spacer(minLength: 0)
            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete task", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DaymarkStyle.muted)
                    .frame(width: 30, height: 36)
            }
            .accessibilityLabel("More options for \(item.title)")
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DaymarkStyle.panel, in: RoundedRectangle(cornerRadius: 20))
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete task", systemImage: "trash")
            }
        }
    }
}
