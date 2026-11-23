# Daymark

A SwiftUI task manager for iPhone. Each day starts with a fresh page. The app keeps today and the preceding six calendar days, saving tasks locally on the phone. Tasks can have due times and local notifications at the due time.

## Open and install

1. Unzip the project, then open `Daymark.xcodeproj` in a recent Xcode that supports your phone's iOS version.
2. Select the **Daymark** target, then **Signing & Capabilities**. Choose your Apple development team and change the bundle identifier from `com.example.daymark` to a unique identifier, such as `com.yourname.daymark`.
3. Connect your unlocked iPhone 15, select it as the run destination, and press **Run**. If prompted on the phone, enable Developer Mode and trust your Mac.
4. When you first create a task with a reminder, allow notifications. Notifications can later be managed in iPhone Settings.

The deployment target is iOS 18.0, so the app can run on newer iOS versions, including the iOS 27 version you reported. The latest available Xcode may need to be installed to recognize iOS 27 devices.

## Use

- Tap **Add a task** to enter a title. Due time and reminder can be toggled independently by switching off the due time or reminder.
- Tap the circle beside a task to complete or reopen it. Completing a task cancels its pending reminder.
- Tap the ellipsis or long press a task to delete it.
- Select a day in the seven-day strip to review its tasks. Tasks older than six days before today are removed automatically when the app opens or crosses into a new day.

All data stays on the device in the app's Application Support folder. Deleting the app deletes the stored task history. No account or network connection is needed.
