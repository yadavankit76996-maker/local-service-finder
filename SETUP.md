# Local Service Finder — public shared version

This version is designed for a public static website connected to Supabase. It contains no fake facility records. The public can search published services and submit suggestions. Only an account explicitly authorized in `admin_users` can access the admin dashboard and publish services.

## Files
- `index.html`: public service search, filters, map, nearest-first sorting, directions
- `suggest.html`: public submission form; saves suggestions to a pending review queue
- `admin.html`: admin sign-in, suggestion review, add/edit/delete services, publish/unpublish
- `config.js`: your Supabase project URL and browser-safe anon/publishable key
- `supabase-schema.sql`: database tables and Row Level Security policies
- `style.css`, `app.js`, `suggest.js`, `admin.js`: UI and application logic

## A. Create the shared database
1. Create a Supabase project at https://supabase.com/ and keep your database password private.
2. In the Supabase dashboard, open **SQL Editor**.
3. Open `supabase-schema.sql`, copy its full contents into a new SQL query and run it.
4. `config.js` has been prefilled with the Project URL and browser-safe publishable key you supplied. The publishable key is intended for browser use; never use a secret or service-role key in frontend code.
5. Because the database was created using an earlier SQL script in chat, open `compatibility-migration.sql`, copy its full contents into Supabase SQL Editor, and click Run once. This adds the two columns the admin dashboard expects.

## B. Create your administrator account
1. In Supabase Dashboard, open **Authentication → Users** and add/invite the administrator email account you control. Set a strong unique password; do not share it.
2. Copy the user's UUID from the Users list.
3. Your administrator UID was already added to `public.admin_users` during setup, so do not repeat this step unless the dashboard says your account is unauthorized. For reference, the SQL to add an administrator is:

   ```sql
   insert into public.admin_users (user_id)
   values ('PASTE-USER-UUID-HERE');
   ```

4. Only user IDs intentionally inserted into `admin_users` can administer records. Do not add public users to this table. There is no public admin registration form.
5. Open `admin.html` and sign in with the authorized account. If the project requires email confirmation, confirm the account first.

## C. Test locally
From this folder, run:

```bash
py -m http.server 8000
```

Then open:
- Public page: http://localhost:8000/
- Suggestion form: http://localhost:8000/suggest.html
- Admin dashboard: http://localhost:8000/admin.html

Location permission normally works on `localhost`. For a hosted website, use HTTPS so browser location features work reliably.

## D. Publish so anyone can use it
1. Upload this folder to a static host such as Netlify, Cloudflare Pages, or GitHub Pages. For a beginner, a static host with drag-and-drop deployment is easiest.
2. Make sure `index.html`, `admin.html`, `suggest.html`, `config.js`, `style.css`, `app.js`, `admin.js`, and `suggest.js` are all included in the deployed root.
3. Open the hosted public URL on a second device and test search and submissions. Use the admin URL only for authorized management.
4. In Supabase Authentication URL settings, add your deployed site URL to the allowed Site URL / Redirect URLs as applicable.

## Security and limitations
- Supabase Row Level Security is the real access control; hiding an admin link is not security.
- The browser-safe anon/publishable key is expected to be visible in the frontend. Database access is restricted by the RLS policies in the SQL file. Never place the service-role/secret key in frontend files.
- Public suggestions are stored as pending records and are not published automatically. This version does not send an email notification; you can review the queue in the admin dashboard. Email notifications require a server-side function/provider and should never be implemented by exposing a secret key in browser JavaScript.
- The website currently stores no actual survey results. Add only records you have genuinely checked. Mark a service verified only after you have performed the checks described in your field-survey method.
- A static public site and Supabase may have free-tier limits. Check current provider plans before relying on it for a large audience.
- Leaflet and OpenStreetMap tiles require internet access. Follow the tile provider's usage policy if the site becomes popular.
