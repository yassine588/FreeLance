# ETAP Fleet & Energy Management Platform 🚛⚡

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![WebSockets](https://img.shields.io/badge/WebSocket-Real--Time-orange?style=for-the-badge)](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)

An enterprise-grade cross-platform fleet management and real-time energy commodity tracking system built for industrial logistics and transportation workflows (ETAP context).

---

## 📌 Key Highlights

- **Real-Time Energy & Commodity Tracking**: Live streaming of energy commodity prices (crude oil, fuel indexes) powered by **WebSockets** and financial data feeds (`yahoo-finance2`).
- **Role-Based Access Control (RBAC)**: Tailored dashboards and access levels for:
  - 👑 **Admin**: Global platform governance and user approvals.
  - 📋 **Chef de Parc (Fleet Manager)**: Fleet supervision, driver mission assignments, and resource allocation.
  - 🚚 **Chauffeur (Driver)**: Active mission tracking, vehicle check-in, and status updates.
  - ⚙️ **Operator**: Daily operational control and input logs.
- **Fleet & Vehicle Lifecycle**:
  - Vehicle registration, status monitoring, and mileage logs.
  - Mission creation, assignment, and completion tracking.
  - Maintenance & repair management (`reparation`) with full history.
- **Cross-Platform Mobile Interface**: Smooth, responsive UX built with Flutter and Provider state management.

---

## 🏗️ Architecture & Tech Stack

```text
┌─────────────────────────────────┐
│     Flutter Client (Mobile)     │
│   (etap - Dart, Provider, UI)   │
└────────────────┬────────────────┘
                 │ REST / WebSockets
┌────────────────▼────────────────┐
│       Node.js / Express API      │
│ (Server.js, RBAC, Controllers)  │
└───────┬─────────────────┬───────┘
        │                 │
┌───────▼───────┐ ┌───────▼───────┐
│ MongoDB Atlas │ │ Yahoo Finance │
│ (Mongoose)    │ │ (Live Feed)   │
└───────────────┘ └───────────────┘
```

### Backend (`/Server`)
- **Runtime**: Node.js (ES Modules)
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Live Updates**: WebSocket (`ws`) server for broadcasting real-time market data
- **Security**: JWT & `bcryptjs` password hashing, CORS configuration

### Mobile Application (`/etap`)
- **Framework**: Flutter (Dart SDK >= 3.6.0)
- **State Management**: Provider
- **Design System**: Material 3 components tailored for industrial fleet operations

---

## 🚀 Getting Started

### 1. Prerequisites
- [Node.js](https://nodejs.org/) (v18+)
- [MongoDB](https://www.mongodb.com/) (Local instance or Atlas URI)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.6+)

---

### 2. Backend Setup

```bash
# Navigate to the Server folder
cd Server

# Install dependencies
npm install

# Configure your environment variables (.env)
PORT=3000
DB_URI=mongodb://127.0.0.1:27017/etap_fleet
JWT_SECRET=your_jwt_secret_key

# Run the server
node Server.js
```

---

### 3. Flutter App Setup

```bash
# Navigate to the Flutter project folder
cd etap

# Fetch dependencies
flutter pub get

# Run on an emulator or connected device
flutter run
```

---

## 📂 Repository Structure

```text
├── Server/
│   ├── config/          # Database & server configuration
│   ├── controllers/     # Route logic & controllers
│   ├── models/          # Mongoose data schemas
│   ├── routes/          # Express API route endpoints
│   └── Server.js        # Server entry point & WebSocket handler
└── etap/
    ├── lib/
    │   ├── Components/  # Role-based screens (Admin, Chef de Parc, Driver...)
    │   ├── models/      # Data models
    │   ├── providers/   # State management providers
    │   ├── services/    # HTTP and WebSocket network services
    │   └── main.dart    # Application entry point
    └── pubspec.yaml     # Flutter dependencies & metadata
```

---

## 👨‍💻 Author

**Yassine Karfouh**
- GitHub: [@yassine588](https://github.com/yassine588)
- Email: [yassine.karfou7@gmail.com](mailto:yassine.karfou7@gmail.com)
