# Bringit Africa — Rider App

Flutter mobile application for the Bringit Africa delivery rider module.

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.x installed
- Android Studio with Android SDK
- Your Laravel backend running

### 2. Configure API URL

Open `lib/core/constants/api_constants.dart` and update the base URL:

```dart
// Android Emulator (localhost)
static const String baseUrl = 'http://10.0.2.2/CustomerService/api';

// Physical device (replace with your machine's local IP)
static const String baseUrl = 'http://192.168.1.100/CustomerService/api';
```

To find your machine's IP on Windows:

```
ipconfig
```

On Mac/Linux:

```
ifconfig
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run
```

### 5. Test Login

Use the rider credentials you created in your Laravel backend.

Default test account from your setup:

- Email: rakatydik@mailinator.com
- Password: (your password)

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/api_constants.dart   ← UPDATE BASE URL HERE
│   ├── theme/app_theme.dart
│   └── services/api_service.dart
└── features/
    ├── auth/          ← Login
    ├── orders/        ← Orders list + detail + M-Pesa
    ├── dashboard/     ← Home + bottom nav
    ├── wallet/        ← Wallet screen
    ├── notifications/ ← Notifications
    └── profile/       ← Profile + logout
```

## API Endpoints Used

| Action        | Method        | Endpoint         |
| ------------- | ------------- | ---------------- | ---------------------- | --- |
| Login         | POST          | /v1/rider/login  |
| Logout        | POST          | /v1/rider/logout |
| Get Orders    | GET           | /v1/orders       |
| <!--          | Update Status | PATCH            | /v1/orders/{id}/status | --> |
| Update Status | PUT           | /v1/orders/{id}  |

| STK Push | POST | /payments/mpesa/stk-push |
| Manual Mpesa | POST | /v1/orders/{id}/verify-mpesa |
| Rider Status | PATCH | /v1/rider/status |

## Features Implemented

- ✅ Login with Bearer token auth (Sanctum)
- ✅ Auto-login if token exists
- ✅ Dashboard with order stats
- ✅ Online/Offline toggle
- ✅ Orders list with tabs (All / Active / Delivered / Pending)
- ✅ Pull to refresh
- ✅ Order detail with full product list
- ✅ M-Pesa STK Push
- ✅ Manual M-Pesa code entry
- ✅ Status update bottom sheet
- ✅ Reschedule with notes
- ✅ Release code confirmation
- ✅ Call client (phone dialler)
- ✅ SMS client
- ✅ WhatsApp with quick templates
- ✅ Status history timeline
- ✅ Profile screen
- ✅ Secure token storage
