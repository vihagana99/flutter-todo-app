# Simple Todo App - Node.js Backend (MySQL)

Flutter + Node.js practice project ekak wenuwen hadapu simple backend eka. Data store karanna MySQL use karanawa.

## Setup

### 1. MySQL install karanna (nathinam)
Computer eke MySQL nathi nam install karanna - Windows eken [MySQL Installer](https://dev.mysql.com/downloads/installer/) or XAMPP use karanna puluwan. Mac eken `brew install mysql`.

### 2. Database + tables hadanna
`schema.sql` file eka run karanna:
```bash
mysql -u root -p < schema.sql
```
(Password ekak nathi nam `-p` eka danna epa). Meken `todo_app` database eka + `users`, `tasks` tables hadenawa.

Terminal eken karanna amaaru nam, MySQL Workbench / phpMyAdmin eke `schema.sql` eke content eka copy-paste karala run karanna puluwan.

### 3. `.env` file eka update karanna
```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=<oyage mysql password eka danna>
DB_NAME=todo_app
```

### 4. Dependencies install + run
```bash
npm install
npm start
```

Server eka run wenne `http://localhost:5000` walata (`.env` file eke `PORT` change karanna puluwan).

## API Endpoints

### Auth
| Method | Endpoint             | Body                                  | Description        |
|--------|----------------------|----------------------------------------|---------------------|
| POST   | /api/auth/register    | `{ name, email, password }`           | New user hadanawa   |
| POST   | /api/auth/login       | `{ email, password }`                 | Login + token eka   |

Response eken `token` eka enawa - ithuru requests walata `Authorization: Bearer <token>` header eka widihata use karanna.

### Tasks (all protected - token eka one)
| Method | Endpoint          | Body                              | Description         |
|--------|-------------------|-------------------------------------|----------------------|
| GET    | /api/tasks        | -                                    | Task okkoma balanawa |
| POST   | /api/tasks        | `{ title }`                        | Task ekak add karanawa |
| PUT    | /api/tasks/:id    | `{ title?, completed? }`           | Task update karanawa |
| DELETE | /api/tasks/:id    | -                                    | Task delete karanawa |

## Flutter walin call karanna hodadi

`http` package eken:

```dart
final response = await http.post(
  Uri.parse('http://10.0.2.2:5000/api/auth/login'), // Android emulator localhost
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);
```

Real device eken test karanawa nam, `localhost` wenuwata computer eke local IP eka (e.g. `192.168.1.x`) use karanna.

## Note

`node_modules` ekak upload karanna epa - `npm install` karaddi automatically hadenawa. Production project ekakadi `.env` file eka git eken exclude karanna (`.gitignore` eke already thiyenawa).
