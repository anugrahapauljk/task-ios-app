import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool
    let onSave: (String, Date?, Bool) -> Void

    @State private var title = ""
    @State private var hasDueTime = true
    @State private var reminderEnabled = true
    @State private var dueTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: now) ?? now
        return calendar.date(bySetting: .minute, value: 0, of: nextHour) ?? nextHour
    }()
    @State private var showTimeWarning = false

    var body: some View {
        ZStack {
            DaymarkStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("A NEW MOMENT")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .tracking(2.5)
                                .foregroundStyle(DaymarkStyle.coral)
                            Text("Add a task")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(DaymarkStyle.cream)
                        }
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(DaymarkStyle.cream)
                                .frame(width: 34, height: 34)
                                .background(DaymarkStyle.panelLight, in: Circle())
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        label("TASK NAME")
                        TextField("What needs doing?", text: $title)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(DaymarkStyle.cream)
                            .tint(DaymarkStyle.coral)
                            .padding(18)
                            .background(DaymarkStyle.panel, in: RoundedRectangle(cornerRadius: 17))
                            .focused($titleFocused)
                            .submitLabel(.done)
                    }

                    VStack(spacing: 0) {
                        Toggle(isOn: $hasDueTime) {
                            settingLabel("Due time", subtitle: "Give this task a time", icon: "clock")
                        }
                        .tint(DaymarkStyle.coral)
                        if hasDueTime {
                            Divider().overlay(DaymarkStyle.panelLight).padding(.vertical, 15)
                            DatePicker("Time", selection: $dueTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .tint(DaymarkStyle.coral)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(DaymarkStyle.cream)
                        }
                    }
                    .padding(18)
                    .background(DaymarkStyle.panel, in: RoundedRectangle(cornerRadius: 20))

                    if hasDueTime {
                        Toggle(isOn: $reminderEnabled) {
                            settingLabel("Remind me", subtitle: "Notify me at the due time", icon: "bell")
                        }
                        .tint(DaymarkStyle.coral)
                        .padding(18)
                        .background(DaymarkStyle.panel, in: RoundedRectangle(cornerRadius: 20))
                    }

                    Button(action: save) {
                        Text("Create task")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(DaymarkStyle.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(DaymarkStyle.coral, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .alert("Choose a future time", isPresented: $showTimeWarning) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A reminder needs a due time later today. Choose a later time or switch off Remind me.")
        }
        .preferredColorScheme(.dark)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy, design: .rounded))
            .tracking(2)
            .foregroundStyle(DaymarkStyle.muted)
    }

    private func settingLabel(_ title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(DaymarkStyle.lilac)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DaymarkStyle.cream)
                Text(subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(DaymarkStyle.muted)
            }
        }
    }

    private func save() {
        let dueAt: Date? = hasDueTime ? Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: dueTime),
            minute: Calendar.current.component(.minute, from: dueTime),
            second: 0,
            of: .now
        ) : nil
        if hasDueTime && reminderEnabled && (dueAt ?? .distantPast) <= .now {
            showTimeWarning = true
            return
        }
        onSave(title, dueAt, hasDueTime && reminderEnabled)
        dismiss()
    }
}
