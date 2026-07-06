# Backend Requirements Documentation

This document outlines the requirements for the backend API that will interface with the new Flutter application, covering all functional requirements from the legacy Java application.

## 1. Authentication & Identification
### `/login` (POST)
- **Payload:** `password` (String), `nfcId` (String).
- **Functionality:** Authenticate user via password and NFC card mapping.

### `/guest-info` (GET)
- **Payload:** `pin` (String).
- **Functionality:** Retrieve guest booking details for guest-based orders (Legacy `guestInfoQuery`).

## 2. Menu Management
### `/menu` (GET)
- **Parameters:** `categoryId` (Optional), `currentTime` (Optional).
- **Functionality:** Retrieve menu items filtered by category and time (Legacy `menuTimeQuery`, `menuTimeQueryByCategory`).

## 3. Transaction & Receipt Management
### `/transactions` (POST)
- **Payload:** `staffId`, `items` (List), `totalAmount`, `paymentMethod`, `bookingId`.
- **Functionality:** Record transaction, update guest status (Legacy `regMenuTransQuery`, `updateGuestUsedQuery`).

### `/receipt-details` (GET)
- **Functionality:** Retrieve company name and generate receipt number (Legacy `getCompanyNameQuery`, `generateReceiptQuery`).

## 4. Float/Cash Management
### `/float-accounts` (GET/POST)
- **Functionality:** Manage float accounts and record transactions (Legacy `checkFloatAccExists`, `regFloatTransQuery`, `updateFloatAccountsQuery`).

## 5. Database Schema
The backend must replicate the legacy database logic:
- `staff`: Auth and ID mapping.
- `menus`: Item details, category, start/end time.
- `menu_transactions`: Transaction logs.
- `department_booking_details`: Guest booking tracking.
- `float_accounts`: Cash management tracking.
