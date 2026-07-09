# Todo App - Web Version

Plain HTML, CSS, and JavaScript frontend for the same Node.js/Express + MySQL backend used by the Flutter app. No build step, no framework - open in a browser and it just works.

## Setup

1. Make sure the backend is running:
   ```bash
   cd todo_backend
   npm start
   ```
   It should be live at `http://localhost:5000`.

2. Open `web_project/login.html` directly in your browser, **or** serve the folder with a simple local server (recommended, avoids some browser file:// restrictions):
   ```bash
   cd web_project
   npx serve .
   ```
   Then visit the URL it prints (e.g. `http://localhost:3000/login.html`).

## Structure

```
web_project/
├── login.html
├── register.html
├── index.html        (main task list - requires login)
├── css/style.css
└── js/
    ├── api.js         (all backend API calls)
    ├── login.js
    ├── register.js
    └── app.js          (task list logic, filters, modals)
```

## Notes

- The token is stored in `localStorage` (not `sharedPreferences` like Flutter, but same idea - keeps you logged in between visits).
- `js/api.js` uses `http://localhost:5000/api` as the base URL, since the browser and the backend run on the same machine. If you deploy the backend elsewhere, update `BASE_URL` in that file.
- Dark mode preference is also saved in `localStorage`.
