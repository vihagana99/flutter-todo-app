# Simple Todo App - Node.js Backend (MySQL)

This is a simple backend created for a Flutter + Node.js practice project. MySQL is used to store the data.

---

## Prerequisites

Before running the project, install the following:

- Node.js (v18 or later recommended)
- MySQL Server
- MySQL Workbench (optional but recommended)

---

## Step 1 - Install MySQL

### Windows
1. Download **MySQL Installer** from the official MySQL website.
2. Run the installer.
3. Select **Developer Default**.
4. Continue with the installation.
5. Set a password for the `root` user when prompted.
6. Finish the installation.

### Mac
```bash
brew install mysql
brew services start mysql
```

### Alternative (Windows)
You can also install **XAMPP** and use the MySQL server included with it.

---

## Step 2 - Install MySQL Workbench

1. Download **MySQL Workbench** from the official MySQL website.
2. Run the installer.
3. Select **MySQL Workbench**.
4. Click **Next** and complete the installation.
5. Open MySQL Workbench.
6. Create a connection using:
   - Hostname: `localhost`
   - Port: `3306`
   - User: `root`
   - Password: the password you set during MySQL installation

---

## Step 3 - Create the Database and Tables

Run the `schema.sql` file.

### Using Command Line
```bash
mysql -u root -p < schema.sql
```

If you do not have a password for MySQL, remove `-p`.

### Using MySQL Workbench
1. Open MySQL Workbench.
2. Open the `schema.sql` file.
3. Copy all the SQL code.
4. Paste it into a new SQL tab.
5. Click the **Execute (lightning icon)** button.

This will create:
- `todo_app` database
- `users` table
- `tasks` table

---

## Step 4 - Configure Environment Variables

Create a `.env` file in the project root and add:

```env
PORT=5000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=todo_app

JWT_SECRET=your_jwt_secret_key
```

Replace `your_mysql_password` with your actual MySQL password.

---

## Step 5 - Install Dependencies

```bash
npm install
```

---

## Step 6 - Run the Server

```bash
npm start
```

The server will run at:

```
http://localhost:5000
```

---

# API Endpoints

## Authentication

### Register
**POST** `/api/auth/register`

Request body:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "123456"
}
```

### Login
**POST** `/api/auth/login`

Request body:
```json
{
  "email": "john@example.com",
  "password": "123456"
}
```

Response:
```json
{
  "token": "JWT_TOKEN_HERE",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

Use the token in the `Authorization` header:

```
Authorization: Bearer JWT_TOKEN_HERE
```

---

## Tasks (Protected Routes)

### Get All Tasks
**GET** `/api/tasks`

### Create Task
**POST** `/api/tasks`

Request body:
```json
{
  "title": "Learn Node.js"
}
```

### Update Task
**PUT** `/api/tasks/:id`

Request body:
```json
{
  "title": "Learn Node.js Backend",
  "completed": true
}
```

### Delete Task
**DELETE** `/api/tasks/:id`

---

# Flutter Example

```dart
final response = await http.post(
  Uri.parse('http://10.0.2.2:5000/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': email,
    'password': password,
  }),
);
```

### For Android Emulator
Use:
```
10.0.2.2
```

### For a Real Device
Use your computer's local IP address, for example:
```
http://192.168.1.236:5000
```

Make sure both the phone and the computer are connected to the same Wi-Fi network.

---

# Project Structure

```
project-root/
│
├── .env
├── package.json
├── server.js
├── schema.sql
│
├── config/
│   └── db.js
│
├── routes/
│   ├── auth.js
│   └── tasks.js
│
├── middleware/
│   └── authMiddleware.js
│
└── controllers/
    ├── authController.js
    └── taskController.js
```

---

# Useful Commands

Install dependencies:
```bash
npm install
```

Run server:
```bash
npm start
```

Run in development mode (with nodemon):
```bash
npm run dev
```

---

# Notes

- Do not upload the `node_modules` folder to GitHub.
- Add `.env` to `.gitignore`.
- Keep your database password and JWT secret private.
- For production, use a strong `JWT_SECRET` and secure database credentials.

---

# Author

Simple Flutter + Node.js + MySQL practice backend.
