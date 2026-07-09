# Todo App

Full-stack Todo application - Flutter frontend + Node.js/Express backend with MySQL.

## Project Structure

```
.
├── todo_backend/     # Node.js + Express + MySQL API
└── todo_flutter/     # Flutter mobile app
```

## Features

- User authentication (JWT-based register/login)
- Create, edit, delete, and complete tasks
- Task priority (low / medium / high)
- Due dates with overdue highlighting
- Categories
- Notes on tasks
- Search and filter (status + category)
- Dark mode
- Animated UI (task add/complete transitions, swipe to delete)

## Prerequisites

- [Node.js](https://nodejs.org) (LTS version)
- [MySQL](https://dev.mysql.com/downloads/installer/) (or MySQL Workbench / XAMPP)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode (for emulator/simulator) or a physical device

---

## 1. Database Setup (MySQL)

Create the database and tables by running the schema below.

**Option A - Command line:**
```bash
mysql -u root -p < todo-backend/schema.sql
```

**Option B - MySQL Workbench:**
1. Open MySQL Workbench and connect to your local instance
2. Open a new SQL tab (`Ctrl+T`)
3. Paste the schema below
4. Select all (`Ctrl+A`) and execute (`Ctrl+Shift+Enter`)

```sql
CREATE DATABASE IF NOT EXISTS todo_app;
USE todo_app;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
  due_date DATE NULL,
  category VARCHAR(50) DEFAULT 'General',
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

Confirm it worked - in Workbench, refresh the **SCHEMAS** panel and check `todo_app` has `users` and `tasks` tables.

---

## 2. Backend Setup

```bash
cd todo_backend
npm install
```

Open `.env` and set your MySQL credentials:

```
PORT=5000
JWT_SECRET=change_this_to_a_random_secret

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=todo_app
```

Start the server:

```bash
npm start
```

You should see:

```
Server running on http://localhost:5000
```

Verify it's working - open `http://localhost:5000` in a browser, you should see:

```json
{"message":"Todo API is running"}
```

---

## 3. Flutter App Setup

```bash
cd todo_flutter
flutter pub get
```

Open `lib/services/api_service.dart` and set the correct `baseUrl` depending on where you're running the app:

| Environment | baseUrl |
|---|---|
| Android Emulator | `http://10.0.2.2:5000/api` |
| iOS Simulator | `http://localhost:5000/api` |
| Real device (USB/WiFi) | `http://<your-computer-local-IP>:5000/api` |

To find your computer's local IP (for real device testing):
- **Windows:** `ipconfig` → look for "IPv4 Address"
- **Mac/Linux:** `ifconfig` → look for `inet` under your WiFi adapter

If using a real device, make sure it's on the **same WiFi network** as your computer, and allow port 5000 through your firewall:

```powershell
# Windows PowerShell (as Administrator)
New-NetFirewallRule -DisplayName "Node Backend 5000" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

Run the app:

```bash
flutter run
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `Cannot find module 'xyz'` | Run `npm install` inside `todo-backend/` |
| `Connection refused` in Flutter | Wrong `baseUrl` - check the table above |
| `ER_ACCESS_DENIED_ERROR` from MySQL | Check `DB_USER` / `DB_PASSWORD` in `.env` |
| Backend won't start, port in use | Change `PORT` in `.env` to something else (e.g. `5001`) |

---

## API Reference

### Auth
| Method | Endpoint | Body |
|---|---|---|
| POST | `/api/auth/register` | `{ name, email, password }` |
| POST | `/api/auth/login` | `{ email, password }` |

### Tasks (require `Authorization: Bearer <token>` header)
| Method | Endpoint | Body / Query |
|---|---|---|
| GET | `/api/tasks?search=&status=&category=` | - |
| GET | `/api/tasks/categories` | - |
| POST | `/api/tasks` | `{ title, priority, dueDate, category, notes }` |
| PUT | `/api/tasks/:id` | `{ title?, completed?, priority?, dueDate?, category?, notes? }` |
| DELETE | `/api/tasks/:id` | - |
