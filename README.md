# 🕒 Timely – Smart Todo App

**Timely** is a beautifully designed, feature-rich Todo app built with **Flutter** and **Hive** for local offline storage.  
Inspired by Todoist, Timely helps you manage your day with clarity, structure, and productivity.

---

## ✨ Features

- ✅ **Task Management**
  - Add, edit, delete, and mark tasks as completed
  - Group tasks by projects (Inbox + custom projects)
  - Set priorities (High, Medium, Low)
  - Assign due dates using a scrollable calendar

- 🛎️ **Reminders & Notifications**
  - Set custom reminders for tasks
  - Requests **notification + exact alarm permissions** (Android 13+)
  - Schedules local notifications and auto-cancels when completed

- 🗂️ **Projects**
  - Create and color-code custom projects
  - View tasks by project for better organization

- 📅 **Smart Calendar Picker**
  - Scrollable Clean Calendar with friendly labels like _Today_, _Tomorrow_

- 📖 **Completed Tasks View**
  - Dedicated screen to view previously completed tasks

- ⚙️ **Settings Page**
  - Toggle notifications
  - Navigate to completed tasks
  - Prompt user for permission access (notifications/exact alarms)

- 💾 **Offline-First**
  - Uses **Hive** for persistent local data storage

---

## 📱 Tech Stack

- **Flutter** – UI toolkit for natively compiled apps
- **Hive** – Lightweight local NoSQL DB
- **flutter_local_notifications** – For task reminders
- **scrollable_clean_calendar** – Custom calendar picker
- **flutter_slidable** – Swipeable task actions
- **intl** – Smart date formatting

---

## 🚀 Getting Started

```bash
git clone https://github.com/svijithprasad/timely-todo-app.git
cd timely-todo-app
flutter pub get
flutter run
