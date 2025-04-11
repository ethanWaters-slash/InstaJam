# 🎸 InstaJam

InstaJam is a SwiftUI-powered iOS app designed to help musicians connect with each other for jam sessions, practice, or collaboration. Users can build profiles, discover nearby players, and chat in real time — all backed by Firebase.

---

## 📱 Features

- 🔐 **Authentication**: Sign up or log in with email/password (Firebase Auth)
- 🧑‍🎤 **Profile Setup**: Input name, instruments, genres, skill level, and a short bio
- 🔍 **Discovery**: Filter musicians by instruments and genres
- 💬 **Messaging**: Real-time 1-on-1 chat with typing indicators and unread message badges
- 📲 **Push Notifications**: Firebase Cloud Messaging (FCM) support
- 🎨 **Custom UI**: Clean and musical design theme with reusable components like `FilterChip`

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15+
- Swift 5.9+
- Firebase project with:
  - Firestore
  - Authentication (Email/Password)
  - Firebase Messaging (optional for push notifications)

### Installation

1. **Clone this repo**:
   ```bash
   git clone https://github.com/your-username/InstaJam.git
