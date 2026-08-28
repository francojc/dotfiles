# Google Workspace extension

Vendored and adapted from `Geun-Oh/pi-google-workspace` (MIT). Tools for Google Drive, Docs, Sheets, and Slides with OAuth token refresh.

## Differences from upstream

- Imports from `@earendil-works/pi-coding-agent` and `typebox` (pi-managed).
- Client credentials (Client ID / Client Secret) are never written to disk. They resolve at runtime from:
  1. `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` env vars
  2. `pass show GWS/GOOGLE_CLIENT_ID` / `pass show GWS/GOOGLE_CLIENT_SECRET`
  3. Interactive prompt in `/gws-setup` (fallback; not persisted)
- `~/.pi/agent/google-workspace/oauth.json` stores **only** tokens + redirect URI (mode 0600).
- No `session_start` footer status (avoids clashing with the custom footer extensions).

## Setup

1. Google Cloud project with Drive, Docs, Sheets, Slides APIs enabled.
2. OAuth consent screen with scopes: `drive`, `documents`, `presentations`, `spreadsheets`. Add your account as test user if in Testing.
3. OAuth client (Desktop app recommended; if Web app, redirect URI `http://127.0.0.1:53682/oauth2callback`).
4. Store credentials:
   ```bash
   pass insert GWS/GOOGLE_CLIENT_ID
   pass insert GWS/GOOGLE_CLIENT_SECRET
   ```
5. In pi: `/reload`, then `/gws-setup`.

## Commands

- `/gws-setup` – run OAuth flow, save tokens
- `/gws-logout` – delete local tokens

## Tools

Drive: `google_drive_list`, `google_drive_download`, `google_drive_upload`, `google_drive_create_folder`
Docs: `google_docs_read`, `google_docs_create`, `google_docs_append_text`, `google_docs_replace_all_text`, `google_docs_download` (pdf/docx/md/txt/rtf/odt/html_zip)
Sheets: `google_sheets_create`, `google_sheets_read`, `google_sheets_update_values`
Slides: `google_slides_read`, `google_slides_replace_text`
Status: `google_workspace_status`

## Notes

- First consent must grant a `refresh_token`; re-run `/gws-setup` if missing or scopes changed.
- `google_docs_download` with format `md` uses the built-in Docs-to-Markdown converter (headings, lists, tables, inline styles).
